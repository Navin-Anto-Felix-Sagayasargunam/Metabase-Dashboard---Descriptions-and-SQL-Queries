-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Inactive Users
-- Card ID: 237
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:31
================================================================================

SELECT 
    CASE 
        WHEN COUNT(DISTINCT _id) >= 1000000000 
            THEN TO_CHAR(ROUND(COUNT(DISTINCT _id) / 1000000000.0, 1), 'FM999999990.0') || 'B'
        WHEN COUNT(DISTINCT _id) >= 1000000 
            THEN TO_CHAR(ROUND(COUNT(DISTINCT _id) / 1000000.0, 1), 'FM999999990.0') || 'M'
        WHEN COUNT(DISTINCT _id) >= 1000 
            THEN TO_CHAR(ROUND(COUNT(DISTINCT _id) / 1000.0, 1), 'FM999999990.0') || 'K'
        ELSE TO_CHAR(COUNT(DISTINCT _id), 'FM999999990')
    END AS formatted_count
FROM customers_v4
WHERE last_activity_date <= CURRENT_DATE - INTERVAL '100 day';
