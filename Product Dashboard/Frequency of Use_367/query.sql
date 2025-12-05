-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Frequency of Use
-- Card ID: 367
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:24
================================================================================

SELECT 
    TO_CHAR(DATE_TRUNC('day', date), 'Mon FMDD,YYYY') AS activity_date,
    AVG(sessionsperuser) AS avg_sessions_per_user
FROM google_analytics_sessionsduration
WHERE date::date BETWEEN CURRENT_DATE - INTERVAL '10 days' AND CURRENT_DATE
GROUP BY DATE_TRUNC('day', date)
ORDER BY DATE_TRUNC('day', date);
