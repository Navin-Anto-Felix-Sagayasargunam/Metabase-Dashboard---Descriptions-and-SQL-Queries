-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Debt Reduction
-- Card ID: 375
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:04
================================================================================

WITH monthly_debt AS (
    SELECT
        DATE_TRUNC('month', last_updated::timestamp) AS month_start,
        SUM(
            CASE 
                WHEN available_balance_debit_or_credit = 'credit' 
                THEN available_balance_amount 
                ELSE 0 
            END
        ) AS total_debt
    FROM accounts_v4
    WHERE is_deleted = 'False'
      AND include_in_nav = 'True'
      AND account_display_type = 'Loan'
      -- Properly convert string to date using TO_DATE
      [[AND DATE_TRUNC('month', last_updated::timestamp) >= DATE_TRUNC('month', TO_DATE({{start_month}}, 'YYYY-MM'))]]
      [[AND DATE_TRUNC('month', last_updated::timestamp) <= DATE_TRUNC('month', TO_DATE({{end_month}}, 'YYYY-MM'))]]
    GROUP BY DATE_TRUNC('month', last_updated::timestamp)
),
debt_with_prev AS (
    SELECT
        month_start,
        total_debt,
        LAG(total_debt) OVER (ORDER BY month_start) AS prev_month_debt
    FROM monthly_debt
)
SELECT
    TO_CHAR(month_start, 'Mon YYYY') AS month_label,
	month_start,
    total_debt,
    prev_month_debt,
    prev_month_debt - total_debt AS debt_difference,
    CASE
        WHEN prev_month_debt - total_debt > 0 THEN 'Debt Decreased'
        WHEN prev_month_debt - total_debt < 0 THEN 'Debt Increased'
        ELSE 'No Change'
    END AS change_status
FROM debt_with_prev
WHERE prev_month_debt IS NOT NULL
ORDER BY month_start;
