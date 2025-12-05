-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Activated Users
-- Card ID: 239
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:12
================================================================================

SELECT 
    CASE 
        WHEN COUNT(*) >= 1000000000 
            THEN TO_CHAR(ROUND(COUNT(*) / 1000000000.0, 1), 'FM999999990.0') || 'B'
        WHEN COUNT(*) >= 1000000 
            THEN TO_CHAR(ROUND(COUNT(*) / 1000000.0, 1), 'FM999999990.0') || 'M'
        WHEN COUNT(*) >= 1000 
            THEN TO_CHAR(ROUND(COUNT(*) / 1000.0, 1), 'FM999999990.0') || 'K'
        ELSE TO_CHAR(COUNT(*), 'FM999999990')
    END AS total_registered_users
FROM customers_v4
WHERE is_deleted = false
and first_account_link_date is not NULL;

--and first_account_link_date is not null 
--and deactivated = false
--WHERE created_at IS NOT NULL;