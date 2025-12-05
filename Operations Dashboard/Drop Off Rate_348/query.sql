-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Drop Off Rate
-- Card ID: 348
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:04
================================================================================

SELECT 'Total Customers' AS step, COUNT(*) AS value
FROM customers_v4

UNION ALL

SELECT 'Drop-off (Never Linked + Deleted)' AS step, COUNT(*) AS value
FROM customers_v4
WHERE first_account_link_date IS NULL AND is_deleted = TRUE

UNION ALL

SELECT 'Active Users (Linked + Not Deleted)' AS step, COUNT(*) AS value
FROM customers_v4
WHERE first_account_link_date IS NOT NULL AND is_deleted = FALSE

UNION ALL

SELECT 'Dropped After Linking (Linked + Deleted)' AS step, COUNT(*) AS value
FROM customers_v4
WHERE first_account_link_date IS NOT NULL AND is_deleted = TRUE;

