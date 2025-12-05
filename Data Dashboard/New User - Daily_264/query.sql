-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: New User - Daily
-- Card ID: 264
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:34
================================================================================

WITH daily_counts AS (
    SELECT
        CAST(creation_date AS DATE) AS activity_date,
        COUNT(DISTINCT _id) AS customer_count
    FROM customers_v4
    WHERE CAST(creation_date AS DATE) < COALESCE({{end_date}}, CURRENT_DATE)  -- exclude today if partial
      AND CAST(creation_date AS DATE) >= COALESCE({{start_date}}, CURRENT_DATE - INTERVAL '7 days')
    GROUP BY CAST(creation_date AS DATE)
)
SELECT
    activity_date,
    customer_count,
    LAG(customer_count) OVER (ORDER BY activity_date) AS previous_day_count,
    ROUND(
        (customer_count::float - LAG(customer_count) OVER (ORDER BY activity_date))
        / NULLIF(LAG(customer_count) OVER (ORDER BY activity_date), 0) * 100,
        2
    ) AS pct_change_vs_prev_day
FROM daily_counts
ORDER BY activity_date ASC;
