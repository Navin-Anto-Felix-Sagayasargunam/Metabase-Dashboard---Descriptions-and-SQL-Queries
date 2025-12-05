-- Dashboard: Sales Dashboard
-- Dashboard ID: 55
-- Chart: Age wise splitup
-- Card ID: 298
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:29
================================================================================

WITH customers_with_age AS (
    SELECT
        c._id,
        FLOOR(EXTRACT(DAY FROM (CURRENT_DATE - c.date_of_birth)) / 365.25) AS age
    FROM customers_v4 c
)
SELECT
    CASE
		--when age is null then 'Not Available'
        WHEN age < 20 THEN ' Less than 20'
        WHEN age BETWEEN 21 AND 30 THEN '21-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        WHEN age BETWEEN 51 AND 60 THEN '51-60'
        WHEN age BETWEEN 61 AND 65 THEN '61-65'
		--WHEN age BETWEEN 65 AND 100 THEN '65+'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS user_count
FROM customers_with_age
GROUP BY age_group
ORDER BY age_group ASC;
