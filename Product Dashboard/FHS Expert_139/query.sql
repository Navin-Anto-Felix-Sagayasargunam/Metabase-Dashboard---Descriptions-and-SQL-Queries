-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: FHS Expert
-- Card ID: 139
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:23
================================================================================

WITH target_period AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', CURRENT_DATE), 'YYYYMM') AS pay_period,
		TO_CHAR(DATE_TRUNC('month', CURRENT_DATE + INTERVAL '1 month'), 'YYYYMM') AS next_pay_period
)
SELECT
    COUNT(DISTINCT customer_id) AS users_count
FROM financial_health_score_v4 fhs
WHERE score > 60   AND score <= 80
  AND pay_period = (SELECT pay_period FROM target_period);