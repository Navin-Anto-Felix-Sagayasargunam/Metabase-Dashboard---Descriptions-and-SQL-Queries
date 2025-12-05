-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Budget Adherence Rate
-- Card ID: 547
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:24
================================================================================

SELECT
    TO_CHAR(TO_DATE(pay_period::text, 'YYYYMM'), 'Mon YYYY') AS pay_period,
	pay_period as pay_period_ts,
    COUNT(DISTINCT CASE 
        WHEN (total_amount / planned_amount_amount) * 100 <= 100 THEN customer_id
    END) AS customers_within_budget,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        (COUNT(DISTINCT CASE 
            WHEN (total_amount / planned_amount_amount) * 100 <= 100 THEN customer_id
        END)::numeric / COUNT(DISTINCT customer_id)) * 100, 2
    ) AS pct_users_within_budget
FROM cached_2_category_totals_v4 cctv
WHERE planned_amount_amount > 0
  AND spending_group_description IN ('Recurring','Day-to-day')
  AND pay_period::int BETWEEN TO_CHAR({{start_date}}, 'YYYYMM')::int 
                          AND TO_CHAR({{end_date}}, 'YYYYMM')::int
  AND pay_period::int <= TO_CHAR(date_trunc('month', current_date) - interval '1 month', 'YYYYMM')::int
GROUP BY pay_period
ORDER BY pay_period::int;
