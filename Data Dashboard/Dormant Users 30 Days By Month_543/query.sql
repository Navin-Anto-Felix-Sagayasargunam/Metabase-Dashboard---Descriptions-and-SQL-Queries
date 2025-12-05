-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Dormant Users 30 Days By Month
-- Card ID: 543
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:42
================================================================================

SELECT
    TO_CHAR(DATE_TRUNC('month', last_activity_date), 'Mon-YYYY') AS month_label,
    COUNT(*) AS dormant_users_0_30_days
FROM sessions_v4
WHERE (last_activity_date <= CURRENT_DATE - INTERVAL '30 day'
       OR last_activity_date IS NULL)
  [[AND last_activity_date >= {{start_date}}]]
  [[AND last_activity_date <= LEAST({{end_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 day')]]
GROUP BY DATE_TRUNC('month', last_activity_date)
ORDER BY DATE_TRUNC('month', last_activity_date);

