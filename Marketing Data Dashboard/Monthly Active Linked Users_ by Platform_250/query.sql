-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Monthly Active Linked Users, by Platform
-- Card ID: 250
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:35
================================================================================

WITH monthly_platform AS (
    SELECT
        DATE_TRUNC('month', CAST(s.created_date AS date)) AS month_start,
        TO_CHAR(DATE_TRUNC('month', CAST(s.created_date AS date)), 'Mon YYYY') AS month_label,
        CASE 
            WHEN s.parsed_platform LIKE '%Flutter%' THEN s.Platform_information_device_type 
            ELSE s.parsed_platform 
        END AS n_Parsed_Plat,
        COUNT(DISTINCT a.customer_id) AS customers_with_session
    FROM account_logins_v4 a
    JOIN sessions_v4 s  
        ON s.customer_id = a.customer_id
    WHERE a.refresh_status = 0
      AND a.is_deleted = false
      AND CAST(s.created_date AS date) >= COALESCE({{start_date}}, DATEADD(year, -1, CURRENT_DATE))
      AND CAST(s.created_date AS date) <= COALESCE({{end_date}}, CURRENT_DATE)
      AND DATE_TRUNC('month', CAST(s.created_date AS date)) < DATE_TRUNC('month', CURRENT_DATE)  -- exclude current month
    GROUP BY 1, 2, 3
)
SELECT *
FROM monthly_platform

UNION ALL

SELECT
    month_start,
    month_label,
    'Total' AS n_Parsed_Plat,
    SUM(customers_with_session) AS customers_with_session
FROM monthly_platform
GROUP BY month_start, month_label
ORDER BY month_start, n_Parsed_Plat;
