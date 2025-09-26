SELECT 
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
    EXTRACT(MONTH FROM job_posted_date) AS date_month
FROM job_postings_fact
LIMIT 5;

SELECT COUNT(job_id) AS job_count,
    EXTRACT(MONTH FROM job_posted_date) AS month 
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY month
ORDER BY job_count DESC;

SELECT '2023-02-19'::DATE,
    '123'::INTEGER,
    'true'::BOOLEAN,
    '3.14'::REAL;



--PROBLEM 1

SELECT 
    job_schedule_type,
    ROUND(AVG(salary_hour_avg)) AS hourly_avg,
    ROUND(AVG(salary_year_avg)) AS yearly_avg
FROM job_postings_fact
WHERE job_posted_date::date < '2023-06-01'
GROUP BY job_schedule_type
ORDER BY job_schedule_type ASC;

--PROBLEM 2

SELECT 
    COUNT(job_id) AS job_count,
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month
FROM job_postings_fact
GROUP BY month
ORDER BY month;

--PROBLEM 3

SELECT 
    company_dim.name AS company_name,
    COUNT(job_postings_fact.job_id) AS job_count
FROM job_postings_fact INNER JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_postings_fact.job_health_insurance = TRUE
    AND  EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 2
GROUP BY company_name 
HAVING COUNT(job_postings_fact.job_id) > 0
ORDER BY job_count DESC;

