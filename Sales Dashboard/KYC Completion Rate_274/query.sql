-- Dashboard: Sales Dashboard
-- Dashboard ID: 55
-- Chart: KYC Completion Rate
-- Card ID: 274
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:33
================================================================================

WITH total_customers AS (
    SELECT COUNT(DISTINCT _id) AS total_users
    FROM customers_v4
    WHERE is_deleted = false
),
kyc_completed AS (
    SELECT COUNT(DISTINCT customer_id) AS kyc_users
    FROM kyc_results_v4
    WHERE am_l_result_is_eligible = 'True'
)
SELECT
 --   t.total_users,
 --   k.kyc_users,
    ROUND((k.kyc_users::decimal / NULLIF(t.total_users, 0)) * 100, 2) AS kyc_completion_rate_pct
FROM total_customers t
CROSS JOIN kyc_completed k;
