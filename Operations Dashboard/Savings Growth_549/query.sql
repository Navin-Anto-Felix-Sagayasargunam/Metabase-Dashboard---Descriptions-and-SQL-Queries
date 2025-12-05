-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Savings Growth
-- Card ID: 549
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:05
================================================================================

WITH customer_savings AS (
    SELECT
        customer_id,
        pay_period,
        liquidity_ratio_amount_in_bank_and_saving_account::numeric AS current_month_savings,
        LAG(liquidity_ratio_amount_in_bank_and_saving_account::numeric) OVER (
            PARTITION BY customer_id ORDER BY pay_period
        ) AS prev_month_savings
    FROM financial_health_score_v4
    -- Include data only between start_date and end_date
    WHERE pay_period BETWEEN 
        TO_CHAR(DATE_TRUNC('month', {{start_date}}), 'YYYYMM')::int
        AND 
        TO_CHAR(DATE_TRUNC('month', {{end_date}}), 'YYYYMM')::int
),

latest_month AS (
    -- Keep only the records corresponding to the end_date month
    SELECT *
    FROM customer_savings
    WHERE pay_period = TO_CHAR(DATE_TRUNC('month', {{end_date}}), 'YYYYMM')::int
)

SELECT
    customer_id,
    pay_period,
    current_month_savings,
    prev_month_savings,
    current_month_savings - COALESCE(prev_month_savings, 0) AS savings_difference,

    -- Formatted difference for visualization (B/M/K)
    CASE
        WHEN current_month_savings - COALESCE(prev_month_savings, 0) >= 1000000000 
            THEN ROUND((current_month_savings - COALESCE(prev_month_savings, 0))/1000000000.0,2)::text || 'B'
        WHEN current_month_savings - COALESCE(prev_month_savings, 0) >= 1000000    
            THEN ROUND((current_month_savings - COALESCE(prev_month_savings, 0))/1000000.0,2)::text || 'M'
        WHEN current_month_savings - COALESCE(prev_month_savings, 0) >= 1000       
            THEN ROUND((current_month_savings - COALESCE(prev_month_savings, 0))/1000.0,2)::text || 'K'
        ELSE (current_month_savings - COALESCE(prev_month_savings, 0))::text
    END AS savings_difference_fmt,

    -- Change direction label
    CASE
        WHEN current_month_savings > COALESCE(prev_month_savings, 0) THEN 'Increase'
        WHEN current_month_savings < COALESCE(prev_month_savings, 0) THEN 'Decrease'
        ELSE 'No Change'
    END AS change_status

FROM latest_month
ORDER BY customer_id;
