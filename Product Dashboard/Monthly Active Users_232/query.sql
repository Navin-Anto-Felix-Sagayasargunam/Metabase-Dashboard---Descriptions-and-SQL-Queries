-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Monthly Active Users
-- Card ID: 232
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:08
================================================================================

SELECT
    DATE_TRUNC('month', se.created_date) AS month_start,
    TO_CHAR(DATE_TRUNC('month', se.created_date), 'Mon YYYY') AS month_label,
    COUNT(DISTINCT se.customer_id) AS active_customers
FROM sessions_v4 se
WHERE se.created_date >= COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months')
  AND se.created_date <= COALESCE({{end_date}}, CURRENT_DATE)
  AND DATE_TRUNC('month', created_date) < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY DATE_TRUNC('month', se.created_date)
ORDER BY month_start;
