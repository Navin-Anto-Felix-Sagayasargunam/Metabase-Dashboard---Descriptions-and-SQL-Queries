-- Dashboard: Financial Health Score 
-- Dashboard ID: 26
-- Chart: FHS Competitor
-- Card ID: 135
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:17
================================================================================

SELECT
    pay_period::int AS pay_period_int,
    TO_CHAR(TO_DATE(pay_period || '01', 'YYYYMMDD'), 'Mon-YYYY') AS month_label,
    'Financial Fitness – Competitor' AS ffs_level,
    COUNT(DISTINCT customer_id) AS users_count
FROM financial_health_score_v4
WHERE score > 40 
  AND score <= 60
  -- Filter pay_period between start_date and end_date in YYYYMM format
  [[AND pay_period::int >= TO_CHAR(DATE_TRUNC('month', {{start_date}}::timestamp), 'YYYYMM')::int]]
  [[AND pay_period::int <= TO_CHAR(DATE_TRUNC('month', {{end_date}}::timestamp), 'YYYYMM')::int]]
  -- Only include completed months
  AND pay_period::int < TO_CHAR(DATE_TRUNC('month', CURRENT_DATE), 'YYYYMM')::int
GROUP BY pay_period
ORDER BY pay_period::int;
