-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Activation Rate
-- Card ID: 349
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:04
================================================================================

SELECT
    COUNT(*) AS total_users,
    COUNT(CASE WHEN first_account_link_date IS NOT NULL AND is_deleted = FALSE THEN 1 END) AS activated_users,
    ROUND(
        (COUNT(CASE WHEN first_account_link_date IS NOT NULL AND is_deleted = FALSE THEN 1 END) * 100.0) / COUNT(*),
        2
    ) AS activation_rate_pct
FROM customers_v4;
