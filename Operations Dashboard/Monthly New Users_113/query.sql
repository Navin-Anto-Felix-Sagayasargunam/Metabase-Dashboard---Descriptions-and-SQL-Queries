-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Monthly New Users
-- Card ID: 113
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:55
================================================================================

	SELECT
    TO_CHAR(DATE_TRUNC('month', creation_date), 'Mon YYYY') AS month,
    COUNT(DISTINCT _id) AS monthly_registrations
FROM customers_v4
WHERE date(creation_date) >= COALESCE({{start_date}}, '2020-01-01')
  AND date(creation_date) <= COALESCE({{end_date}}, CURRENT_DATE)
  AND DATE_TRUNC('month', creation_date) < DATE_TRUNC('month', CURRENT_DATE)  -- only completed months
--  AND is_deleted = FALSE
GROUP BY DATE_TRUNC('month', creation_date)
ORDER BY DATE_TRUNC('month', creation_date)
LIMIT 20;
