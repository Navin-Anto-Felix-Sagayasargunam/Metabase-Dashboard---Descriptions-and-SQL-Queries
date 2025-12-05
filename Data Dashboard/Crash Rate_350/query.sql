-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Crash Rate
-- Card ID: 350
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:44
================================================================================


SELECT
    TO_CHAR(DATE(datehour), 'Mon DD, YYYY') AS activity_date,
    ROUND(
        (SUM(crashfreeusersrate) * 100.0 / NULLIF(SUM(crashfreeusersrate) + SUM(crashaffectedusers), 0)),
        2
    ) AS crash_free_users_rate_percent
FROM public.google_analytics_crashdetails
WHERE datehour::date BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
GROUP BY DATE(datehour)
ORDER BY activity_date;


   -- crashfreeusersrate, 
   