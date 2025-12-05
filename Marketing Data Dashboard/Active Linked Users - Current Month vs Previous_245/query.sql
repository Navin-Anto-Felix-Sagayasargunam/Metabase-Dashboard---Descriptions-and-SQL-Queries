-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Active Linked Users - Current Month vs Previous 
-- Card ID: 245
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:34
================================================================================

WITH monthly_rolling AS (
    SELECT
        DATE_TRUNC('month', s.last_activity_date) AS month_start,
        COUNT(DISTINCT s.customer_id) AS active_linked_users_30d
    FROM sessions_v4 AS s
    JOIN account_logins_v4 AS a
      ON s.customer_id = a.customer_id
    WHERE (a.is_deleted IS NULL OR a.is_deleted = FALSE)
      AND a.refresh_status = 0
      AND CAST(s.last_activity_date AS date) >= COALESCE({{start_date}}, ADD_MONTHS(CURRENT_DATE, -6))
      AND CAST(s.last_activity_date AS date) <= COALESCE({{end_date}}, CURRENT_DATE)
    GROUP BY DATE_TRUNC('month', s.last_activity_date)
)
SELECT
    month_start,
    active_linked_users_30d,
    ROUND(
        (
            active_linked_users_30d::float 
            - LAG(active_linked_users_30d) OVER (ORDER BY month_start DESC)
        ) / NULLIF(LAG(active_linked_users_30d) OVER (ORDER BY month_start DESC),0) * 100,
        2
    ) AS pct_change_vs_prev_month
FROM monthly_rolling
ORDER BY month_start ASC;
