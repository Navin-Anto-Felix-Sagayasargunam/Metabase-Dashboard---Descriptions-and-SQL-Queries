-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Churn Rate 
-- Card ID: 240
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:11
================================================================================

WITH inactive AS (
    SELECT COUNT(DISTINCT _id) AS inactive_count
    FROM customers_v4
    WHERE last_activity_date <= CURRENT_DATE - INTERVAL '90 day'
),
total AS (
    SELECT COUNT(DISTINCT _id) AS total_count
    FROM customers_v4
)
SELECT
    inactive.inactive_count,
    total.total_count,
    ROUND(
        (inactive.inactive_count::decimal / NULLIF(total.total_count, 0)) * 100,
        2
    ) AS churn_rate_pct
FROM inactive, total;
