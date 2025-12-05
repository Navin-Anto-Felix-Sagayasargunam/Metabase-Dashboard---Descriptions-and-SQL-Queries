-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Activated Users - Comparison
-- Card ID: 559
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:43
================================================================================

WITH monthly_counts AS (
    SELECT
        DATE_TRUNC('month', creation_date)::date AS month_start,
        COUNT(*) AS user_count
    FROM customers_v4
    WHERE creation_date >= COALESCE({{start_date}}, DATEADD(month, -12, DATE_TRUNC('month', CURRENT_DATE)))
      AND creation_date < DATE_TRUNC('month', CURRENT_DATE)  -- only completed months
      AND creation_date <= COALESCE({{end_date}}, CURRENT_DATE)
	  and is_deleted = 'false'
	  and first_account_link_date is not null
    GROUP BY DATE_TRUNC('month', creation_date)::date
)
SELECT
    mc.month_start,
    mc.user_count,
    ROUND(
        (
            (mc.user_count::float - LAG(mc.user_count) OVER (ORDER BY mc.month_start)) 
            / NULLIF(LAG(mc.user_count) OVER (ORDER BY mc.month_start), 0) * 100
        ), 2
    ) AS pct_change_vs_prev_month
FROM monthly_counts mc
ORDER BY mc.month_start;
