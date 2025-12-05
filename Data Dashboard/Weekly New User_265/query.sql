-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Weekly New User
-- Card ID: 265
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:35
================================================================================

WITH weekly_counts AS (
    SELECT
        DATE_TRUNC('week', creation_date) AS week_start,
        DATE_TRUNC('week', creation_date) + INTERVAL '6 days' AS week_end,
        COUNT(DISTINCT _id) AS customer_count
    FROM customers_v4
    WHERE DATE_TRUNC('week', creation_date) < DATE_TRUNC('week', COALESCE({{end_date}}, CURRENT_DATE))  -- exclude current partial week
      AND DATE_TRUNC('week', creation_date) >= DATE_TRUNC('week', COALESCE({{start_date}}, CURRENT_DATE - INTERVAL '2 weeks'))
    GROUP BY DATE_TRUNC('week', creation_date)
)
SELECT
    TO_CHAR(week_start, 'DD Mon YYYY') || ' - ' || TO_CHAR(week_end, 'DD Mon YYYY') AS week_range,
    customer_count,
    LAG(customer_count) OVER (ORDER BY week_start) AS previous_week_count,
    ROUND(
        (customer_count::float - LAG(customer_count) OVER (ORDER BY week_start))
        / NULLIF(LAG(customer_count) OVER (ORDER BY week_start), 0) * 100,
        2
    ) AS pct_change_vs_prev_week
FROM weekly_counts
ORDER BY week_start ASC;
