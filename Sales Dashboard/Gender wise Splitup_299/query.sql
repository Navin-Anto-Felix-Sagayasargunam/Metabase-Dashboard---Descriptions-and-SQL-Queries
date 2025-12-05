-- Dashboard: Sales Dashboard
-- Dashboard ID: 55
-- Chart: Gender wise Splitup
-- Card ID: 299
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:30
================================================================================

SELECT
    CASE 
        WHEN gender IS NULL OR TRIM(gender) = '' THEN 'Unknown'
        WHEN gender ILIKE 'I prefer not%say' THEN 'I prefer not to say'
        ELSE gender
    END AS gender_group,
    COUNT(DISTINCT _id) AS user_count
FROM customers_v4
where date(creation_date) >= '2020-01-01'
GROUP BY gender_group
ORDER BY user_count DESC;

