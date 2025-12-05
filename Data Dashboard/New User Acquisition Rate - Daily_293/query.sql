-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: New User Acquisition Rate - Daily
-- Card ID: 293
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:34
================================================================================

WITH user_counts AS (
    SELECT 
        DATE_TRUNC('day', creation_date) AS day_start,
        COUNT(*) AS new_users
    FROM customers_v4
    WHERE creation_date >= COALESCE({{start_date}}, CURRENT_DATE - INTERVAL '2 weeks')
      AND creation_date <= COALESCE({{end_date}}, CURRENT_DATE)
    GROUP BY DATE_TRUNC('day', creation_date)
),
running_totals AS (
    SELECT
        day_start,
        new_users,
        SUM(new_users) OVER (ORDER BY day_start ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS users_before
    FROM user_counts
)
SELECT
    day_start,
    new_users,
    COALESCE(users_before, 0) AS users_at_start,
    CASE 
        WHEN COALESCE(users_before, 0) = 0 THEN NULL
        ELSE ROUND((new_users::numeric / users_before) * 100, 2)
    END AS acquisition_rate_pct
FROM running_totals
ORDER BY day_start;
