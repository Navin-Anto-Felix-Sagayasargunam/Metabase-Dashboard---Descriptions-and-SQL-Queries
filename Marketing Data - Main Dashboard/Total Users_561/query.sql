-- Dashboard: Marketing Data - Main Dashboard
-- Dashboard ID: 67
-- Chart: Total Users
-- Card ID: 561
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:26
================================================================================

SELECT 
    profile_type,
    CASE 
        WHEN COUNT(*) >= 1000000000 
            THEN TO_CHAR(ROUND(COUNT(*) / 1000000000.0, 1), 'FM999999990.0') || 'B'
        WHEN COUNT(*) >= 1000000 
            THEN TO_CHAR(ROUND(COUNT(*) / 1000000.0, 1), 'FM999999990.0') || 'M'
        WHEN COUNT(*) >= 1000 
            THEN TO_CHAR(ROUND(COUNT(*) / 1000.0, 1), 'FM999999990.0') || 'K'
        ELSE TO_CHAR(COUNT(*), 'FM999999990')
    END AS  total_customers
FROM (
    SELECT 
        c._id,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type
    FROM customers_v4 c
    LEFT JOIN vault_profiles_v4 v 
        ON c._id = v.customer_id
    GROUP BY c._id, v._t  -- ensures one row per customer
) AS t
WHERE 1=1
[[AND profile_type = {{profile_type}}]]  -- optional Metabase filter
GROUP BY profile_type;

