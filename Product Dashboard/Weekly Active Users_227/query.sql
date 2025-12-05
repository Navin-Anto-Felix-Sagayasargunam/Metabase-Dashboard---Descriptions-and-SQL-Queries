-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Weekly Active Users
-- Card ID: 227
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:08
================================================================================

WITH week_bounds AS (
    SELECT
        DATE_TRUNC('week', COALESCE({{end_date}}, CURRENT_DATE)) - INTERVAL '7 day' AS last_week_start,   -- last completed week
        DATE_TRUNC('week', COALESCE({{end_date}}, CURRENT_DATE)) - INTERVAL '14 day' AS prev_week_start   -- week before last
),
weekly_users AS (
    SELECT 
        DATE_TRUNC('week', se.last_activity_date) AS week_start,
        COUNT(DISTINCT se.customer_id) AS active_users
    FROM sessions_v4 se
    CROSS JOIN week_bounds wb
    WHERE DATE_TRUNC('week', se.created_date) IN (wb.prev_week_start, wb.last_week_start)
      AND se.last_activity_date >= COALESCE({{start_date}}, wb.prev_week_start)
      AND se.last_activity_date <= COALESCE({{end_date}}, wb.last_week_start + INTERVAL '6 day')
    GROUP BY DATE_TRUNC('week', se.last_activity_date)
)
SELECT
    week_start,
    active_users AS weekly_active_users,
    ROUND(
        ((active_users::float - LAG(active_users) OVER (ORDER BY week_start)) 
         / NULLIF(LAG(active_users) OVER (ORDER BY week_start),0) * 100), 2
    ) AS pct_change_vs_prev_week
FROM weekly_users
ORDER BY week_start ASC;
