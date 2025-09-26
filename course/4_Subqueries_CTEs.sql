SELECT *
FROM (--Subquery begins here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;

SELECT 
    name AS company_name,
    company_id
FROM company_dim
WHERE company_id IN (
    SELECT 
        company_id
    FROM 
        job_postings_fact
    WHERE 
        job_no_degree_mention = TRUE
)


/*Find the companies that have the most job openings.
- Get the total number of job postings per company id (job_posting_fact)
- Return the total number of jobs with the company name (company_dim)
*/

WITH company_job_counts AS (
SELECT
    company_id,
    COUNT(*) AS total_jobs
FROM 
    job_postings_fact
GROUP BY
    company_id
)

SELECT 
    company_dim.name AS company_name,
    company_job_counts.total_jobs
FROM company_dim LEFT JOIN company_job_counts ON company_job_counts.company_id = company_dim.company_id
ORDER BY total_jobs DESC;

--Practice
WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skills_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE job_postings.job_work_from_home = true
    GROUP BY skill_id
)

SELECT 
    skills.skill_id,
    skills AS skill_name,
    skills_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY skills_count DESC
limit 5;

--Problem 1
WITH skill_counts AS (
    SELECT
        skill_id,
        COUNT(*) AS count
    FROM skills_job_dim
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_job_dim.job_id
    GROUP BY skill_id
    ORDER BY count DESC
    LIMIT 5
)

SELECT 
    skills.skill_id,
    skills AS skill_name,
    count
FROM skill_counts
INNER JOIN skills_dim AS skills ON skills.skill_id = skill_counts.skill_id
ORDER BY skill_counts DESC
limit 5;

--Problem 2
WITH count_company AS (
    SELECT
        company_dim.name AS company_name,
        COUNT(*) AS job_count
    FROM job_postings_fact
    LEFT JOIN company_dim 
        ON job_postings_fact.company_id = company_dim.company_id
    GROUP BY company_dim.name
    ORDER BY job_count DESC
)

SELECT
    company_name,
    job_count,
    CASE
        WHEN job_count < 10 THEN 'SMALL'
        WHEN job_count BETWEEN 10 AND 50 THEN 'MEDIUM'
        ELSE 'LARGE'
    END AS size_category
FROM count_company

--Problem 3
WITH company_avg AS (
    SELECT
        company_dim.company_id,
        company_dim.name AS company_name,
        ROUND(AVG(job_postings_fact.salary_year_avg)) AS yearly_avg
    FROM job_postings_fact
    LEFT JOIN company_dim 
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE salary_year_avg IS NOT NULL
    GROUP BY company_dim.company_id, company_dim.name
),
total_avg AS (
    SELECT
        ROUND(AVG(yearly_avg)) AS general_avg
    FROM company_avg
)
SELECT
    company_avg.company_name,
    company_avg.yearly_avg,
    total_avg.general_avg
FROM company_avg
CROSS JOIN total_avg
WHERE company_avg.yearly_avg > total_avg.general_avg
ORDER BY company_avg.yearly_avg DESC;


--PROBLEM 4

SELECT
    DISTINCT company_dim.name AS company_name,
    COUNT(DISTINCT job_title) AS unique_jobs
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
GROUP BY company_name
ORDER BY unique_jobs DESC
LIMIT 10


--Problem 5

WITH country_avgs AS (
    SELECT
        job_country AS country,
        ROUND(AVG(salary_year_avg)) AS country_avg
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    GROUP BY country
)

SELECT 
    job_id,
    job_title,
    company_dim.name,
    salary_year_avg,
    country_avgs.country_avg,
    job_country,
    CASE
        WHEN salary_year_avg > country_avgs.country_avg THEN 'Above Average'
        ELSE 'Below Average'
    END AS salary_level,
    EXTRACT(MONTH FROM job_posted_date) AS posting_month
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
LEFT JOIN country_avgs ON job_postings_fact.job_country = country_avgs.country
ORDER BY posting_month DESC


--Problem 6
WITH unique_skills_count AS (
    SELECT
        company_dim.name AS company_name,
        COUNT(DISTINCT skills_job_dim.skill_id) AS skill_count
    FROM job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    LEFT JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    GROUP BY company_name
),
highest_avg_annual_salary AS (
    SELECT 
        company_dim.name AS company_name,
        MAX(salary_year_avg) AS highest_salary
    FROM job_postings_fact
    INNER JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    GROUP BY company_name
)

SELECT 
    DISTINCT company_dim.name AS company_name,
    unique_skills_count.skill_count,
    highest_avg_annual_salary.highest_salary
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
LEFT JOIN highest_avg_annual_salary ON company_dim.name = highest_avg_annual_salary.company_name
LEFT JOIN unique_skills_count ON company_dim.name = unique_skills_count.company_name
ORDER BY company_name ASC