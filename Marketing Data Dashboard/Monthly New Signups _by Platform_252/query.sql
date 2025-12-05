-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Monthly New Signups ,by Platform
-- Card ID: 252
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:36
================================================================================

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', creation_date)::date AS month_start,
        _id AS customer_id
    FROM customers_v4
    WHERE creation_date >= COALESCE({{start_date}}, DATEADD(month, -12, DATE_TRUNC('month', CURRENT_DATE)))
      AND creation_date < DATE_TRUNC('month', CURRENT_DATE)  -- only completed months
      AND creation_date <= COALESCE({{end_date}}, CURRENT_DATE)
)
SELECT
    wk.month_start,
    TO_CHAR(wk.month_start, 'Mon YYYY') AS month_range,
    DATEADD(day, -1, DATEADD(month, 1, wk.month_start)) AS end_date,
    CASE 
        WHEN s.parsed_platform LIKE '%Flutter%' THEN s.Platform_information_device_type 
        ELSE s.parsed_platform 
    END AS n_Parsed_Plat,
    COUNT(DISTINCT s.customer_id) AS Customers_Count
FROM monthly wk
LEFT JOIN sessions_v4 s
    ON wk.customer_id = s.customer_id
    AND s.created_date >= COALESCE({{start_date}}, DATEADD(month, -12, DATE_TRUNC('month', CURRENT_DATE)))
    AND s.created_date < DATE_TRUNC('month', CURRENT_DATE)  -- only completed months
    AND s.created_date <= COALESCE({{end_date}}, CURRENT_DATE)
GROUP BY wk.month_start, n_Parsed_Plat
ORDER BY wk.month_start, n_Parsed_Plat;
