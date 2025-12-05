-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Average Sessions per User - Weekly
-- Card ID: 596
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:26
================================================================================

SELECT
    TO_CHAR(DATE_TRUNC('week', date), 'Mon DD') 
    || ' - ' ||
    TO_CHAR(DATE_TRUNC('week', date) + INTERVAL '6 day', 'Mon DD, YYYY') AS week_range, 
    SUM(sessions) AS total_sessions,
    SUM(totalusers) AS total_users,
    ROUND(SUM(sessions)::numeric / NULLIF(SUM(totalusers), 0), 2) AS avg_sessions_per_user
FROM public.google_analytics_appdetails
WHERE date between {{start_date}} AND {{end_date}}
AND DATE_TRUNC('week', date) < DATE_TRUNC('week', CURRENT_DATE)
GROUP BY
    TO_CHAR(DATE_TRUNC('week', date), 'Mon DD') 
    || ' - ' ||
    TO_CHAR(DATE_TRUNC('week', date) + INTERVAL '6 day', 'Mon DD, YYYY')
ORDER BY
    MIN(DATE_TRUNC('week', date));