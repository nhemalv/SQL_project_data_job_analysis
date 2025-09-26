SELECT
    skills_dim.skills,
    ROUND(AVG(salary_year_avg), 0) AS yearly_avg
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY skills_dim.skills
ORDER BY yearly_avg DESC
LIMIT 25;
