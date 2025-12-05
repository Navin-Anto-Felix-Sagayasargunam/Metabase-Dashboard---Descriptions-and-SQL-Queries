-- Dashboard: Marketing Data - Main Dashboard
-- Dashboard ID: 67
-- Chart: New Paying Users
-- Card ID: 568
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:28
================================================================================

WITH filtered_payments AS (
    SELECT
        p.customer_id,
        DATE_TRUNC('month', p.received_money_succeed_at::timestamp)::date AS month_start,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type
    FROM payment_transaction_log_v4 p
    LEFT JOIN vault_profiles_v4 v
        ON p.customer_id = v.customer_id
    WHERE p.succeed = TRUE
      AND p.received_money_succeed_at::date >= COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months')
	  AND p.received_money_succeed_at::date < DATE_TRUNC('month', CURRENT_DATE)
      AND p.received_money_succeed_at::date < DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE))  -- only completed months
      [[AND CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profile_type}}]] -- optional filter
),
monthly_counts AS (
    SELECT
        month_start,
        profile_type,
        COUNT(DISTINCT customer_id) AS paying_customers
    FROM filtered_payments
    GROUP BY month_start, profile_type
)
SELECT
    mc.month_start,
    TO_CHAR(mc.month_start, 'Mon YYYY') AS month_label,
    mc.profile_type,
    mc.paying_customers,
    LAG(mc.paying_customers) OVER (PARTITION BY mc.profile_type ORDER BY mc.month_start) AS prev_month_customers,
    ROUND(
        (
            (mc.paying_customers::float - LAG(mc.paying_customers) OVER (PARTITION BY mc.profile_type ORDER BY mc.month_start))
            / NULLIF(LAG(mc.paying_customers) OVER (PARTITION BY mc.profile_type ORDER BY mc.month_start), 0) * 100
        ), 2
    ) AS pct_change_vs_prev_month
FROM monthly_counts mc
ORDER BY mc.month_start, mc.profile_type;
