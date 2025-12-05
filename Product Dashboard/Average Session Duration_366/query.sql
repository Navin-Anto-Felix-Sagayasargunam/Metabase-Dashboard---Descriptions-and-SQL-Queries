-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Average Session Duration
-- Card ID: 366
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:25
================================================================================

SELECT 
    DATE(date) AS activity_date,
    sessionsource,
    SUM(sessions) AS total_sessions,
    AVG(averagesessionduration) AS avg_session_duration_seconds,
    SUM(averagesessionduration * sessions) AS total_time_in_app_seconds,
    (SUM(sessions) / NULLIF(AVG(sessionsperuser), 0)) AS approx_users,
    (SUM(averagesessionduration * sessions) / NULLIF(SUM(sessions) / AVG(sessionsperuser), 0)) 
        AS session_length_per_user_seconds
FROM google_analytics_sessionsduration
WHERE date BETWEEN COALESCE( CURRENT_DATE - interval '7 days')
               AND COALESCE( CURRENT_DATE)
GROUP BY DATE(date), sessionsource
ORDER BY DATE(date), sessionsource;
