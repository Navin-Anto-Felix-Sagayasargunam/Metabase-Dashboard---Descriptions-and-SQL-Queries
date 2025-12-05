-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Borrow Product - Sanlam
-- Card ID: 335
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:03
================================================================================

SELECT
    DATE_TRUNC('month', created_at::timestamp) AS month_start,  -- this is the drill-down field
    TO_CHAR(DATE_TRUNC('month', created_at::timestamp), 'Mon-YYYY') AS month_year,
    COUNT(*) AS account_count
FROM accounts_v4
WHERE service_provider_id = '5e4142cc5982e311bcef4a4b'
  AND _t = 'LoanAccount'
  AND is_deleted = 'False'
  AND refresh_status = 0
  AND deactivated = false
GROUP BY DATE_TRUNC('month', created_at::timestamp)
ORDER BY DATE_TRUNC('month', created_at::timestamp);
