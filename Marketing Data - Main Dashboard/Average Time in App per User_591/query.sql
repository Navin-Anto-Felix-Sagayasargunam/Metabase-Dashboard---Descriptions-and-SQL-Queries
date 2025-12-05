-- Dashboard: Marketing Data - Main Dashboard
-- Dashboard ID: 67
-- Chart: Average Time in App per User
-- Card ID: 591
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:28
================================================================================

SELECT
	 DATE_TRUNC('month', date) AS month_start,
    TO_CHAR(DATE_TRUNC('month', date), 'Mon YYYY') AS month_label,
     SUM(userengagementduration) AS total_engagement_time_seconds,
    SUM(activeusers) AS total_active_users, 
    -- Average time per user in seconds
    CASE 
        WHEN SUM(activeusers) > 0 THEN SUM(userengagementduration) / sum(activeusers)
        ELSE 0
    END AS avg_time_per_user_seconds,
    -- Average time per user in minutes
    CASE 
        WHEN SUM(activeusers) > 0 THEN (SUM(userengagementduration) / sum(activeusers)) / 60
        ELSE 0
    END AS avg_time_per_user_minutes
FROM google_analytics_appdetails g
WHERE 1=1
  [[AND g.date::date >= {{start_date}}]]
  [[AND g.date::date <= {{end_date}}]]
--  AND g.countryid IN ('UAE', 'SA')
GROUP BY DATE_TRUNC('month', g.date)
ORDER BY month_start ;
