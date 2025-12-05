-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Monthly New Signups
-- Card ID: 266
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:35
================================================================================

WITH monthly_counts AS (
    SELECT
        DATE_TRUNC('month', creation_date) AS month_start,
        COUNT(DISTINCT _id) AS new_users
    FROM customers_v4
    WHERE DATE_TRUNC('month', creation_date) < DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE))  -- exclude current partial month
      AND DATE_TRUNC('month', creation_date) >= DATE_TRUNC('month', COALESCE({{start_date}}, DATEADD(month, -12, CURRENT_DATE)))
    GROUP BY DATE_TRUNC('month', creation_date)
)
SELECT
    TO_CHAR(month_start, 'Mon YYYY') AS month_range,
    new_users,
    LAG(new_users) OVER (ORDER BY month_start) AS prev_month_users,
    ROUND(
        (new_users::float - LAG(new_users) OVER (ORDER BY month_start))
        / NULLIF(LAG(new_users) OVER (ORDER BY month_start), 0) * 100,
        2
    ) AS pct_change_vs_prev_month,
    CASE 
        WHEN new_users >= 1000000000 THEN ROUND(new_users / 1000000000.0, 1) || 'B'
        WHEN new_users >= 1000000    THEN ROUND(new_users / 1000000.0, 1) || 'M'
        WHEN new_users >= 1000       THEN ROUND(new_users / 1000.0, 1) || 'K'
        ELSE new_users::TEXT
    END AS new_users_display
FROM monthly_counts
ORDER BY month_start ASC;
