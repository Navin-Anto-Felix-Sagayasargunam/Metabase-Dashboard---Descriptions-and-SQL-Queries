-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Partially Connected Users
-- Card ID: 302
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:38
================================================================================

WITH target_period AS (
    SELECT
        CASE
            -- If current month is ongoing, use previous month
            WHEN DATE_TRUNC('month', CURRENT_DATE) = DATE_TRUNC('month', CURRENT_DATE)
            THEN TO_CHAR(DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month', 'YYYYMM')::int
            ELSE TO_CHAR(DATE_TRUNC('month', CURRENT_DATE), 'YYYYMM')::int
        END AS pay_period_int
)
SELECT 
    COUNT(*) AS users_count
FROM financial_health_score_v4 fhs
WHERE score > 0 
  AND score <= 50
  AND pay_period::int = (SELECT pay_period_int FROM target_period);
