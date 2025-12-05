-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Active Linked Users – Last Month vs Earlier
-- Card ID: 257
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:37
================================================================================

WITH month_bounds AS ( SELECT DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)) - INTERVAL '1 month' AS last_month_start, -- last completed month 
DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)) - INTERVAL '2 months' AS prev_month_start -- month before last 
),
monthly_rolling AS ( SELECT DATE_TRUNC('month', s.created_date) AS month_start,
COUNT(DISTINCT s.customer_id) AS active_linked_users FROM sessions_v4 s JOIN account_logins_v4 a ON s.customer_id = a.customer_id
CROSS JOIN month_bounds mb WHERE (a.is_deleted IS NULL OR a.is_deleted = FALSE) 
AND a.refresh_status = 0
AND DATE_TRUNC('month', s.last_activity_date) IN (mb.prev_month_start, mb.last_month_start) AND s.last_activity_date >= COALESCE({{start_date}}, mb.prev_month_start)
AND s.last_activity_date < COALESCE({{end_date}}, mb.last_month_start + INTERVAL '1 month') -- include full last completed month 
GROUP BY DATE_TRUNC('month', s.created_date) )
SELECT month_start, active_linked_users, ROUND( ( active_linked_users::float - LAG(active_linked_users) OVER (ORDER BY month_start) ) / NULLIF(LAG(active_linked_users) OVER (ORDER BY month_start), 0) * 100, 2 ) AS pct_change_vs_prev_month
FROM monthly_rolling ORDER BY month_start ASC;