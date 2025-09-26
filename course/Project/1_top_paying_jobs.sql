SELECT
    company_dim.name AS company_name,
    job_title,
    salary_year_avg,
    job_schedule_type,
    job_posted_date,
    job_work_from_home
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_work_from_home = TRUE 
AND job_title LIKE '%Data Analyst%'
AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;