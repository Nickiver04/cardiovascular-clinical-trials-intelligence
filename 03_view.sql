CREATE VIEW cv_trials_dashboard AS
SELECT
    nct_id,
    brief_title,
    status,
    phase,
    study_type,
    `condition`,
    intervention_name,
    intervention_type,
    lead_sponsor_name,
    sponsor_class,
    start_year,
    enrollment_count,
    enrollment_type,
    duration_days,
    ROUND(duration_days / 365, 1) AS duration_years,
    countries,
    minimum_age,
    maximum_age,
    std_ages,
    results_first_submit_date,
    -- Derived columns for Power BI
    CASE 
        WHEN enrollment_count > 100000 THEN 'Large Registry'
        WHEN enrollment_count >= 1000 THEN 'Large Trial'
        WHEN enrollment_count >= 100 THEN 'Medium Trial'
        WHEN enrollment_count < 100 THEN 'Small Trial'
        ELSE 'Unknown'
    END AS trial_size_category,
    CASE
        WHEN status = 'Completed' THEN 'Finished'
        WHEN status = 'Terminated' THEN 'Stopped Early'
        WHEN status IN ('Recruiting', 'Active, Not Recruiting') THEN 'In Progress'
        ELSE 'Other'
    END AS status_category,
    CASE
        WHEN std_ages LIKE '%CHILD%' AND std_ages LIKE '%OLDER_ADULT%' THEN 'All Ages'
        WHEN std_ages LIKE '%OLDER_ADULT%' THEN 'Elderly Focused'
        WHEN std_ages LIKE '%CHILD%' THEN 'Pediatric'
        WHEN std_ages LIKE '%ADULT%' THEN 'Adult Only'
        ELSE 'Unknown'
    END AS age_group_category
FROM world.clinical_trials;