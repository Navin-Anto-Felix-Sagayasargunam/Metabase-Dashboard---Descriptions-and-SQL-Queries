-- Dashboard: Financial Health Score 
-- Dashboard ID: 26
-- Chart: FHS Enthusiast
-- Card ID: 354
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:18
================================================================================

/*SELECT
--    TO_CHAR(last_updated, 'Mon-YYYY') AS month_label,
--    'Financial Fitness – Elite' AS ffs_level,
    COUNT(distinct customer_id) AS users_count
FROM financial_health_score_v4
WHERE score > 20 AND score <= 40
--GROUP BY month_label
--ORDER BY MIN(last_updated);*/

WITH target_period AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', {{end_date}} ), 'YYYYMM') AS pay_period,
        TO_CHAR(DATE_TRUNC('month', {{end_date}} + INTERVAL '1 month'), 'YYYYMM') AS next_pay_period
)
SELECT
    COUNT(DISTINCT customer_id) AS users_count
FROM financial_health_score_v4 fhs
WHERE score > 20 AND score <= 40
  AND pay_period = (SELECT pay_period FROM target_period);
