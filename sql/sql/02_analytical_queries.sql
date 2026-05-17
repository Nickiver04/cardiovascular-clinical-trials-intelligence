SELECT status,COUNT(*) AS total,ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM world.clinical_trials GROUP BY status ORDER BY total DESC;
SELECt phase, COUNT(*) AS total, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM world.clinical_trials GROUP BY phase ORDER BY total DESC;
SELECT sponsor_class, COUNT(*) AS total,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM world.clinical_trials
GROUP BY sponsor_class ORDER BY total DESC;
SELECT lead_sponsor_name, sponsor_class, COUNT(*) AS total_trials
FROM world.clinical_trials
WHERE lead_sponsor_name IS NOT NULL
GROUP BY lead_sponsor_name, sponsor_class
ORDER BY total_trials DESC LIMIT 10;
SELECT phase, ROUND(AVG(enrollment_count), 0) AS avg_enrollment,
ROUND(MIN(enrollment_count), 0) AS min_enrollment,
ROUND(MAX(enrollment_count), 0) AS max_enrollment
FROM world.clinical_trials
WHERE enrollment_count IS NOT NULL
GROUP BY phase ORDER BY avg_enrollment DESC;
SELECT start_year, COUNT(*) AS total_trials,
ROUND(AVG(enrollment_count), 0) AS average_enrollment
FROM world.clinical_trials
WHERE start_year IS NOT NULL AND start_year BETWEEN 2000 AND 2016
GROUP BY start_year ORDER BY start_year ASC;
SELECT `condition`, COUNT(*) AS total
FROM world.clinical_trials
WHERE `condition` IS NOT NULL
GROUP BY `condition` ORDER BY total DESC LIMIT 15;
SELECT intervention_type, COUNT(*) AS total,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM world.clinical_trials
WHERE intervention_type IS NOT NULL
GROUP BY intervention_type ORDER BY total DESC;
SELECT
ROUND(SUM(CASE WHEN status='Completed' THEN 1 ELSE 0 END) * 100.0 /
SUM(CASE WHEN status IN ('Completed','Terminated') THEN 1 ELSE 0 END), 1) AS completion_rate,
ROUND(SUM(CASE WHEN status='Terminated' THEN 1 ELSE 0 END) * 100.0 /
SUM(CASE WHEN status IN ('Completed','Terminated') THEN 1 ELSE 0 END), 1) AS termination_rate
FROM world.clinical_trials;
SELECT std_ages, COUNT(*) AS total,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM world.clinical_trials
WHERE std_ages IS NOT NULL
GROUP BY std_ages ORDER BY total DESC;
SELECT phase, COUNT(*) AS total_trials,
ROUND(AVG(duration_days), 0) AS avg_duration_days,
ROUND(AVG(duration_days) / 365, 1) AS avg_duration_years
FROM world.clinical_trials
WHERE duration_days IS NOT NULL AND duration_days <> 0
GROUP BY phase ORDER BY avg_duration_days DESC;
