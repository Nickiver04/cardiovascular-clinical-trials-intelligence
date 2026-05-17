import requests
import pandas as pd
import time
import os

BASE_URL = "https://clinicaltrials.gov/api/v2/studies"

FIELDS = [
    "NCTId", "BriefTitle", "OverallStatus", "Phase", "StudyType",
    "Condition", "InterventionName", "InterventionType", "LeadSponsorName",
    "LeadSponsorClass", "StartDate", "PrimaryCompletionDate", "CompletionDate",
    "EnrollmentCount", "EnrollmentType", "LocationCountry",
    "ResultsFirstSubmitDate", "StudyFirstSubmitDate",
    "MinimumAge", "MaximumAge", "StdAge",
]

PARAMS = {
    "query.cond": "cardiovascular",
    "query.term": "heart OR cardiac OR hypertension OR coronary OR atherosclerosis OR arrhythmia OR heart failure",
    "filter.overallStatus": "COMPLETED,TERMINATED,ACTIVE_NOT_RECRUITING,RECRUITING",
    "fields": "|".join(FIELDS),
    "pageSize": 1000,
    "format": "json",
}

OUTPUT_DIR = "data"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def safe_get(d, *keys, default=None):
    for key in keys:
        if isinstance(d, dict):
            d = d.get(key, default)
        elif isinstance(d, list) and isinstance(key, int):
            d = d[key] if key < len(d) else default
        else:
            return default
    return d if d is not None else default


def fetch_trials(max_records=5000):
    all_studies = []
    next_page_token = None
    page = 1
    print("🔍 Fetching cardiovascular trials...")
    while len(all_studies) < max_records:
        params = PARAMS.copy()
        if next_page_token:
            params["pageToken"] = next_page_token
        try:
            response = requests.get(BASE_URL, params=params, timeout=30)
            response.raise_for_status()
            data = response.json()
        except requests.exceptions.RequestException as e:
            print(f"  ⚠️  Request failed on page {page}: {e}")
            break
        studies = data.get("studies", [])
        if not studies:
            break
        all_studies.extend(studies)
        print(f"  ✅ Page {page}: {len(studies)} studies | Total: {len(all_studies)}")
        next_page_token = data.get("nextPageToken")
        if not next_page_token:
            break
        page += 1
        time.sleep(0.5)
    print(f"\n📦 Total fetched: {len(all_studies)}")
    return all_studies


def parse_study(study):
    proto = study.get("protocolSection", {})
    id_mod = proto.get("identificationModule", {})
    status_mod = proto.get("statusModule", {})
    design_mod = proto.get("designModule", {})
    sponsor_mod = proto.get("sponsorCollaboratorsModule", {})
    conditions_mod = proto.get("conditionsModule", {})
    interventions_mod = proto.get("armsInterventionsModule", {})
    locations_mod = proto.get("contactsLocationsModule", {})
    eligibility_mod = proto.get("eligibilityModule", {})

    interventions = interventions_mod.get("interventions", [])
    intervention_name = interventions[0].get("name", None) if interventions else None
    intervention_type = interventions[0].get("type", None) if interventions else None

    conditions = conditions_mod.get("conditions", [])
    condition_str = "; ".join(conditions) if conditions else None

    locations = locations_mod.get("locations", [])
    countries = list(set([loc.get("country") for loc in locations if loc.get("country")]))
    country_str = "; ".join(sorted(countries)) if countries else None

    phases = design_mod.get("phases", [])
    phase_str = "; ".join(phases) if phases else "N/A"

    enrollment = design_mod.get("enrollmentInfo", {})

    minimum_age = eligibility_mod.get("minimumAge", None)
    maximum_age = eligibility_mod.get("maximumAge", None)
    std_ages = eligibility_mod.get("stdAges", [])
    std_ages_str = "; ".join(std_ages) if std_ages else None

    return {
        "nct_id": id_mod.get("nctId"),
        "brief_title": id_mod.get("briefTitle"),
        "overall_status": status_mod.get("overallStatus"),
        "phase": phase_str,
        "study_type": design_mod.get("studyType"),
        "condition": condition_str,
        "intervention_name": intervention_name,
        "intervention_type": intervention_type,
        "lead_sponsor_name": safe_get(sponsor_mod, "leadSponsor", "name"),
        "lead_sponsor_class": safe_get(sponsor_mod, "leadSponsor", "class"),
        "start_date": status_mod.get("startDateStruct", {}).get("date"),
        "primary_completion_date": status_mod.get("primaryCompletionDateStruct", {}).get("date"),
        "completion_date": status_mod.get("completionDateStruct", {}).get("date"),
        "enrollment_count": enrollment.get("count"),
        "enrollment_type": enrollment.get("type"),
        "countries": country_str,
        "study_first_submit_date": status_mod.get("studyFirstSubmitDate"),
        "results_first_submit_date": status_mod.get("resultsFirstSubmitDate"),
        "minimum_age": minimum_age,
        "maximum_age": maximum_age,
        "std_ages": std_ages_str,
    }


def parse_all_studies(studies):
    records = [parse_study(s) for s in studies]
    df = pd.DataFrame(records)
    print(f"📊 Parsed shape: {df.shape}")
    return df


def clean_data(df):
    print("🧹 Cleaning data...")
    df = df.drop_duplicates(subset="nct_id")
    df = df.dropna(subset=["nct_id", "brief_title", "overall_status"])

    phase_map = {
        "PHASE1": "Phase 1", "PHASE2": "Phase 2", "PHASE3": "Phase 3",
        "PHASE4": "Phase 4", "PHASE1; PHASE2": "Phase 1/2",
        "PHASE2; PHASE3": "Phase 2/3", "EARLY_PHASE1": "Early Phase 1", "N/A": "N/A",
    }
    df["phase_clean"] = df["phase"].str.upper().map(phase_map).fillna("Other/Unknown")

    status_map = {
        "COMPLETED": "Completed", "TERMINATED": "Terminated",
        "ACTIVE_NOT_RECRUITING": "Active, Not Recruiting", "RECRUITING": "Recruiting",
        "SUSPENDED": "Suspended", "WITHDRAWN": "Withdrawn",
    }
    df["status_clean"] = df["overall_status"].map(status_map).fillna(df["overall_status"])

    sponsor_map = {
        "INDUSTRY": "Industry", "NIH": "NIH", "FED": "Federal",
        "OTHER_GOV": "Other Government", "INDIV": "Individual",
        "NETWORK": "Network", "OTHER": "Other", "UNKNOWN": "Unknown",
    }
    df["sponsor_class_clean"] = df["lead_sponsor_class"].map(sponsor_map).fillna("Unknown")

    for col in ["start_date", "primary_completion_date", "completion_date", "study_first_submit_date"]:
        df[col] = pd.to_datetime(df[col], errors="coerce")

    df["start_year"] = df["start_date"].dt.year
    df["enrollment_count"] = pd.to_numeric(df["enrollment_count"], errors="coerce")
    df["duration_days"] = (df["completion_date"] - df["start_date"]).dt.days
    df.loc[df["duration_days"] < 0, "duration_days"] = None
    df["study_type"] = df["study_type"].str.title().fillna("Unknown")
    df["intervention_type"] = df["intervention_type"].str.title().fillna("Unknown")

    final_cols = [
        "nct_id", "brief_title", "status_clean", "phase_clean",
        "study_type", "condition", "intervention_name", "intervention_type",
        "lead_sponsor_name", "sponsor_class_clean", "start_date",
        "primary_completion_date", "completion_date", "start_year",
        "enrollment_count", "enrollment_type", "duration_days",
        "countries", "study_first_submit_date", "results_first_submit_date",
        "minimum_age", "maximum_age", "std_ages",
    ]
    df = df[final_cols].rename(columns={
        "status_clean": "status",
        "phase_clean": "phase",
        "sponsor_class_clean": "sponsor_class",
    })
    print(f"  ✅ Final shape: {df.shape}")
    return df


def save_data(df):
    out_path = os.path.join(OUTPUT_DIR, "cv_trials_cleaned.csv")
    df.to_csv(out_path, index=False)
    print(f"\n💾 Saved to: {out_path}")
    print(f"   Rows: {len(df)} | Columns: {len(df.columns)}")
    print(f"\n📈 Status:\n{df['status'].value_counts().to_string()}")
    print(f"\n📈 Phase:\n{df['phase'].value_counts().to_string()}")
    print(f"\n📈 Sponsor class:\n{df['sponsor_class'].value_counts().to_string()}")
    return out_path
raw_studies = fetch_trials(max_records=5000)
df_raw = parse_all_studies(raw_studies)
df_clean = clean_data(df_raw)
save_data(df_clean)
