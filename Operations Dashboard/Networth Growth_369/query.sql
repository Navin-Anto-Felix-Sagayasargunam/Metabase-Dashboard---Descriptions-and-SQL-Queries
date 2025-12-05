-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Networth Growth
-- Card ID: 369
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:03
================================================================================

WITH monthly_balances AS (
    SELECT
        DATE_TRUNC('month', last_updated::date) AS month_start_ts,
        SUM(CASE WHEN available_balance_debit_or_credit = 'credit' THEN available_balance_amount ELSE 0 END) AS total_assets,
        SUM(CASE WHEN available_balance_debit_or_credit = 'debit' THEN available_balance_amount ELSE 0 END) AS total_liabilities
    FROM accounts_v4
    WHERE is_deleted = 'False'
      AND include_in_nav = 'True'
      [[AND last_updated >= {{start_date}}]]
      [[AND last_updated <= {{end_date}}]]
    GROUP BY DATE_TRUNC('month', last_updated::DATE)
)
SELECT
    month_start_ts AS month_start,
    TO_CHAR(month_start_ts, 'Mon YYYY') AS month_label,
    total_assets,
    total_liabilities,
    CASE
        WHEN (total_assets - total_liabilities) >= 1000000000 THEN ROUND((total_assets - total_liabilities)/1000000000.0,2)::text || 'B'
        WHEN (total_assets - total_liabilities) >= 1000000    THEN ROUND((total_assets - total_liabilities)/1000000.0,2)::text || 'M'
        WHEN (total_assets - total_liabilities) >= 1000       THEN ROUND((total_assets - total_liabilities)/1000.0,2)::text || 'K'
        ELSE (total_assets - total_liabilities)::text
    END AS networth_fm
FROM monthly_balances
ORDER BY month_start_ts;
