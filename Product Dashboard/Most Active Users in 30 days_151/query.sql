-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Most Active Users in 30 days
-- Card ID: 151
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:21
================================================================================

SELECT 
    TO_CHAR(DATE_TRUNC('month', last_activity_date), 'Mon YYYY') AS month_label,
    COUNT(DISTINCT customer_id) AS active_users
FROM sessions_v4
WHERE last_activity_date IS NOT NULL
  [[AND last_activity_date >= DATE_TRUNC('month', {{start_date}})]]
  [[AND last_activity_date <= DATE_TRUNC('month', {{end_date}})]]
GROUP BY DATE_TRUNC('month', last_activity_date)
ORDER BY DATE_TRUNC('month', last_activity_date);
