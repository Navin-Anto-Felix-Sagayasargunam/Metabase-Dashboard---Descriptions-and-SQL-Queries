-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Average Sessions per User - Monthly
-- Card ID: 597
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:27
================================================================================

SELECT
    TO_CHAR(DATE_TRUNC('month', date), 'Mon YYYY') AS month_label,
    SUM(sessions) AS total_sessions,
    SUM(totalusers) AS total_users,
    ROUND(SUM(sessions)::numeric / NULLIF(SUM(totalusers), 0), 2) AS avg_sessions_per_user
FROM public.google_analytics_appdetails
WHERE date BETWEEN {{start_date}} AND {{end_date}}
GROUP BY DATE_TRUNC('month', date)
ORDER BY DATE_TRUNC('month', date);
