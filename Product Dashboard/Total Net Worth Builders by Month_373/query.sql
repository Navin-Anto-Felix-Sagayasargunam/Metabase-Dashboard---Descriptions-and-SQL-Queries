-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Total Net Worth Builders by Month
-- Card ID: 373
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:24
================================================================================

WITH monthly_balances AS (
    SELECT
        DATE_TRUNC('month', last_updated::timestamp) AS month_start,
        SUM(
            CASE 
                WHEN available_balance_debit_or_credit = 'credit' 
                THEN available_balance_amount 
                ELSE 0 
            END
        ) AS total_assets
    FROM accounts_v4
    WHERE is_deleted = 'False'
      AND include_in_nav = 'True'
      AND last_updated::date BETWEEN {{start_date}} AND {{end_date}}
    GROUP BY DATE_TRUNC('month', last_updated::timestamp)
),
balances_with_prev AS (
    SELECT
        month_start,
        total_assets,
        LAG(total_assets) OVER (ORDER BY month_start) AS prev_month_assets
    FROM monthly_balances
)
SELECT
    TO_CHAR(month_start, 'Mon YYYY') AS month_label,
    total_assets,
    prev_month_assets,
    CASE 
        WHEN total_assets > prev_month_assets THEN 'Increase'
        WHEN total_assets < prev_month_assets THEN 'Decrease'
        ELSE 'No Change'
    END AS change_status
FROM balances_with_prev
WHERE prev_month_assets IS NOT NULL
ORDER BY month_start;
