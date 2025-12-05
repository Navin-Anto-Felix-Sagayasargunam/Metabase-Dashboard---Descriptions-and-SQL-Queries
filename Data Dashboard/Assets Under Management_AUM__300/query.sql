-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Assets Under Management(AUM)
-- Card ID: 300
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:43
================================================================================

SELECT
    COALESCE(UPPER(account_type), UPPER(account_display_type)) AS funding_category,
    CASE
        WHEN SUM(available_balance_amount) >= 1000000000 
            THEN TO_CHAR(ROUND(SUM(available_balance_amount) / 1000000000.0, 2), 'FM999999990.00') || 'B'
        WHEN SUM(available_balance_amount) >= 1000000 
            THEN TO_CHAR(ROUND(SUM(available_balance_amount) / 1000000.0, 2), 'FM999999990.00') || 'M'
        WHEN SUM(available_balance_amount) >= 1000 
            THEN TO_CHAR(ROUND(SUM(available_balance_amount) / 1000.0, 2), 'FM999999990.00') || 'K'
        ELSE TO_CHAR(ROUND(SUM(available_balance_amount), 2), 'FM999999990.00')
    END AS "AUM_Total"
FROM accounts_v4
WHERE available_balance_amount > 0
  AND available_balance_debit_or_credit = 'credit'
  AND is_deleted = 'False'
  AND deactivated = false
  AND refresh_status = 0
GROUP BY COALESCE(UPPER(account_type), UPPER(account_display_type))
ORDER BY SUM(available_balance_amount) DESC;
