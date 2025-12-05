-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: New User Acquisition Rate  Monthly 
-- Card ID: 323
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:13
================================================================================

WITH user_counts AS (
    SELECT 
        DATE_TRUNC('month', creation_date) AS month_start,
        COUNT(*) AS new_users
    FROM customers_v4
    WHERE 1=1
      [[AND date(creation_date) >= {{start_date}}]]
      [[AND date(creation_date) <= {{end_date}}]]
	  AND DATE_TRUNC('month', creation_date) < DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY DATE_TRUNC('month', creation_date)
),
running_totals AS (
    SELECT
        month_start,
        new_users,
        SUM(new_users) OVER (ORDER BY month_start ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS users_before
    FROM user_counts
)
SELECT
    TO_CHAR(month_start, 'Mon YYYY') AS month_label,
    new_users,
    COALESCE(users_before, 0) AS users_at_start,
    CASE 
        WHEN COALESCE(users_before, 0) = 0 THEN NULL
        ELSE ROUND((new_users::numeric / users_before) * 100, 2)
    END AS acquisition_rate_pct
FROM running_totals
ORDER BY month_start;
