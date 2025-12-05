-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Daily Active Users
-- Card ID: 226
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:39
================================================================================

WITH daily_users AS (
    SELECT 
        CAST(se.last_activity_date::date AS DATE) AS activity_date,
        COUNT(DISTINCT se.customer_id) AS active_users
    FROM sessions_v4 se
    WHERE se.last_activity_date::date >= COALESCE({{start_date}}, CURRENT_DATE - INTERVAL '2 day')
      AND se.last_activity_date::date <= COALESCE({{end_date}}, CURRENT_DATE - INTERVAL '1 day')
    GROUP BY CAST(se.last_activity_date::date AS DATE)
)
SELECT
    activity_date,
    active_users,
    ROUND(
        ((active_users::float - LAG(active_users) OVER (ORDER BY activity_date)) 
         / NULLIF(LAG(active_users) OVER (ORDER BY activity_date),0) * 100), 2
    ) AS pct_change_vs_prev_day
FROM daily_users
ORDER BY activity_date ASC;
