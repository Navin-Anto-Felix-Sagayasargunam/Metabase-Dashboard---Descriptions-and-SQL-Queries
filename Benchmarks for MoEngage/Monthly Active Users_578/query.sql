-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Monthly Active Users 
-- Card ID: 578
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:21
================================================================================

WITH month_list AS (
    SELECT DATE_TRUNC('month', DATEADD(month, -i, DATE_TRUNC('month', {{end_date}}))) AS month_start
    FROM (
        SELECT 0 AS i UNION ALL
        SELECT 1 UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9 UNION ALL
        SELECT 10 UNION ALL
        SELECT 11
    ) t
    WHERE DATEADD(month, -i, DATE_TRUNC('month', {{end_date}})) >= DATE_TRUNC('month', {{start_date}})
      AND DATEADD(month, -i, DATE_TRUNC('month', {{end_date}})) < DATE_TRUNC('month', CURRENT_DATE)
)
SELECT
    m.month_start,
    TO_CHAR(m.month_start, 'Mon YYYY') AS month_label,
    COUNT(DISTINCT se.customer_id) AS active_customers,
    LAG(COUNT(DISTINCT se.customer_id)) OVER (ORDER BY m.month_start) AS prev_month_customers,
    ROUND(
        ((COUNT(DISTINCT se.customer_id)::float - 
          LAG(COUNT(DISTINCT se.customer_id)) OVER (ORDER BY m.month_start)) 
         / NULLIF(LAG(COUNT(DISTINCT se.customer_id)) OVER (ORDER BY m.month_start), 0) * 100), 2
    ) AS pct_change_vs_prev_month,
    COUNT(DISTINCT v.customer_id) AS profiles_linked
FROM month_list m

LEFT JOIN sessions_v4 se
    ON DATE_TRUNC('month', se.last_activity_date) = m.month_start

LEFT JOIN vault_profiles_v4 v
    ON se.customer_id = v.customer_id
    AND (
        ({{profile_type}} = 'UAE' AND v._t = 'VaultUAEProfile')
        OR ({{profile_type}} = 'SA'  AND v._t <> 'VaultUAEProfile')
    )

WHERE 
    v.customer_id IS NOT NULL
    AND (
           se.last_activity_date::date BETWEEN DATE_TRUNC('month', CAST({{start_date}} AS date)) 
           AND (DATE_TRUNC('month', CAST({{end_date}} AS date)) + INTERVAL '1 month - 1 day')

        OR TO_TIMESTAMP(se.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS')::date BETWEEN DATE_TRUNC('month', CAST({{start_date}} AS date)) 
           AND (DATE_TRUNC('month', CAST({{end_date}} AS date)) + INTERVAL '1 month - 1 day')
    )

GROUP BY m.month_start
ORDER BY m.month_start ASC;
