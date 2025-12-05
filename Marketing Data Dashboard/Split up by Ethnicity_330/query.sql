-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Split up by Ethnicity 
-- Card ID: 330
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:40
================================================================================

SELECT 
    CASE 
        WHEN ethnicity IS NULL OR TRIM(ethnicity) = '' THEN 'Unknown'
        WHEN LOWER(TRIM(ethnicity)) LIKE 'i prefer%' THEN 'I Prefer Not to Say'
        ELSE INITCAP(TRIM(ethnicity))
    END AS ethnicity_group,
    COUNT(_id) AS user_count
FROM customers_v4
WHERE DATE(creation_date) >= '2023-01-01'
GROUP BY ethnicity_group
ORDER BY user_count DESC;


