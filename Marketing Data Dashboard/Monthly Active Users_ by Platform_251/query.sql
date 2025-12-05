-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Monthly Active Users, by Platform
-- Card ID: 251
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:35
================================================================================

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', creation_date)::date AS month_start,
        _id AS customer_id
    FROM customers_v4
    WHERE creation_date >= COALESCE({{start_date}}, DATEADD(month, -12, DATE_TRUNC('month', CURRENT_DATE)))
      AND creation_date < DATE_TRUNC('month', CURRENT_DATE)  -- only completed months
      AND creation_date <= COALESCE({{end_date}}, CURRENT_DATE)
),
platform_counts AS (
    SELECT
        wk.month_start,
        CASE 
            WHEN s.parsed_platform LIKE '%Flutter%' THEN s.Platform_information_device_type 
            ELSE s.parsed_platform 
        END AS n_Parsed_Plat,
        COUNT(s.customer_id) AS customers_count
    FROM monthly wk
    LEFT JOIN sessions_v4 s
        ON wk.customer_id = s.customer_id
        AND s.created_date >= COALESCE({{start_date}}, DATEADD(month, -12, DATE_TRUNC('month', CURRENT_DATE)))
        AND s.created_date < DATE_TRUNC('month', CURRENT_DATE)  -- only completed months
        AND s.created_date <= COALESCE({{end_date}}, CURRENT_DATE)
    GROUP BY wk.month_start, n_Parsed_Plat
    HAVING COUNT(s.customer_id) > 0
),
combined AS (
    SELECT
        month_start,
        TO_CHAR(month_start, 'Mon YYYY') AS month_range,
        DATEADD(day, -1, DATEADD(month, 1, month_start)) AS end_date,
        n_Parsed_Plat,
        customers_count,
        0 AS sort_order  -- regular platform rows
    FROM platform_counts

    UNION ALL

    SELECT
        month_start,
        TO_CHAR(month_start, 'Mon YYYY') AS month_range,
        DATEADD(day, -1, DATEADD(month, 1, month_start)) AS end_date,
        'Total' AS n_Parsed_Plat,
        SUM(customers_count) AS customers_count,
        1 AS sort_order  -- total row goes after platforms
    FROM platform_counts
    GROUP BY month_start
)
SELECT month_start, month_range, end_date, n_Parsed_Plat, customers_count
FROM combined
ORDER BY month_start, sort_order, n_Parsed_Plat;
