# Cardiovascular Clinical Trials Intelligence Report

A complete end to end data analytics project analyzing **1,257 cardiovascular clinical trials** from ClinicalTrials.gov using Python, MySQL, and Power BI.

## Project Objective

Cardiovascular clinical trial data from ClinicalTrials.gov exists in raw, unstructured JSON format with no immediate analytical value. This project builds a full data pipeline to extract, clean, analyze, and visualize this data — identifying real data quality issues and deriving actionable insights about the cardiovascular research landscape.


## Tech Stack

| Layer | Tool |
|---|---|
| Data Extraction | Python (requests, pandas) |
| Database | MySQL |
| Visualization | Power BI (PL-300) |
| Data Source | ClinicalTrials.gov API v2 |


## Pipeline Architecture
ClinicalTrials.gov API
↓
Python (fetch → parse → clean → export CSV)
↓
MySQL (load → deep clean → analytical queries → VIEW)
↓
Power BI (connect to VIEW → dashboard)

## Project Structure
cardiovascular-clinical-trials-intelligence/
│
├── 01_fetch_and_clean.py
│
├── sql/
│   ├── 01_cleaning.sql
│   ├── 02_analytical_queries.sql
│   └── 03_view.sql
│
├── images/
│   ├── 01_overview.png
│   ├── 02_trial_characteristics.png
│   ├── 03_demographics_trends.png
│   └── 04_key_findings.png
│
└── README.md

## Data Source

**ClinicalTrials.gov API v2**
- Endpoint: `https://clinicaltrials.gov/api/v2/studies`
- Filter: cardiovascular conditions
- Status: Completed, Terminated, Active Not Recruiting, Recruiting
- Records fetched: **1,257 trials**


## Python Pipeline

- Hits the ClinicalTrials.gov API with pagination (1,000 records per page)
- Parses deeply nested JSON into a flat table structure
- Cleans and standardizes phase labels, status labels, sponsor class, dates, enrollment count
- Extracts age eligibility fields
- Calculates trial duration in days
- Exports clean CSV for MySQL loading

```bash
pip install requests pandas
python 01_fetch_and_clean.py
```


## SQL Pipeline

**Cleaning** — whitespace trimming, NULL handling, data type fixes, phase standardization

**11 Analytical Queries** covering status, phase, sponsor class, top sponsors, enrollment averages, year trend, conditions, intervention types, completion rate, age groups, trial duration

**View** — final clean VIEW for Power BI with derived columns: `duration_years`, `trial_size_category`, `status_category`, `age_group_category`


## Key Findings

### Data Quality Issues Identified & Resolved

| Issue | Detail | Action |
|---|---|---|
| Missing start dates | 53% of trials had no start date in API | Documented as API data quality limitation |
| Enrollment outliers | 2 registry studies with 31M+ enrollment | Flagged as Large Registry |

### Analytical Insights

| Finding | Value |
|---|---|
| Total trials analyzed | 1,257 |
| Total enrollments | 4M+ |
| True completion rate | 90.3% |
| Observational trials (no phase) | 68.6% |
| Most studied condition | Hypertension (64 trials) |
| Largest sponsor | NHLBI — 31 trials |
| Device trials | 18% |
| Pediatric trials | Only 3% (61 trials) |
| Avg Phase 3 duration | 3.76 years |

### Notable Outliers

**Drug-Induced Sudden Death & Ventricular Arrhythmia (NCT00102180)** — A pharmacoepidemiologic database study by the University of Pennsylvania analyzing 31 million Medicaid/Medicare records — not a traditional clinical trial.

**MyHeart Counts Cardiovascular Health Study** — A fully digital decentralized trial by Stanford University conducted via an iPhone app, targeting 2 million participants.

### Recommendations

1. Separate registry studies from interventional trials for cleaner enrollment reporting
2. Increase pediatric cardiovascular research — only 3% of trials include children
3. ClinicalTrials.gov should mandate start date entry for all trial registrations
4. Focus funding on underserved conditions such as Peripheral Arterial Disease and Aortic Valve Stenosis

## Author

**Nick Iver Majaw** — PharmD Graduate | Data Analyst

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/nick-iver-majaw)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-black)](https://github.com/Nickiver04)
