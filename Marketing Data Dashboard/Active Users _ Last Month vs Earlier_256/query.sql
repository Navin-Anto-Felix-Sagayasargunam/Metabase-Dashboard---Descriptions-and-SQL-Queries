-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Active Users – Last Month vs Earlier
-- Card ID: 256
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:36
================================================================================

WITH month_list AS ( SELECT DATE_TRUNC('month', DATEADD(month, -i, DATE_TRUNC('month', {{end_date}}))) AS month_start
FROM ( SELECT 1 AS i UNION ALL SELECT 2 ) t -- Only pick months that fall after start_date 
WHERE DATEADD(month, -i, DATE_TRUNC('month', {{end_date}})) >= DATE_TRUNC('month', {{start_date}}) )
SELECT m.month_start,
TO_CHAR(m.month_start, 'Mon YYYY') AS month_label,
COALESCE(COUNT(DISTINCT se.customer_id), 0) AS active_customers,
LAG(COUNT(DISTINCT se.customer_id)) OVER (ORDER BY m.month_start) AS prev_month_customers,
ROUND( ((COUNT(DISTINCT se.customer_id)::float - LAG(COUNT(DISTINCT se.customer_id)) OVER (ORDER BY m.month_start)) / NULLIF(LAG(COUNT(DISTINCT se.customer_id))OVER (ORDER BY m.month_start),0) * 100), 2 ) AS pct_change_vs_prev_month
FROM month_list m
LEFT JOIN sessions_v4 se ON DATE_TRUNC('month', se.last_activity_date) = m.month_start AND ( (se.last_activity_date::date BETWEEN CAST({{start_date}} AS date)
AND CAST({{end_date}} AS date))
OR (TO_TIMESTAMP(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS')::date BETWEEN CAST({{start_date}} AS date) AND CAST({{end_date}} AS date)) )
GROUP BY m.month_start 
ORDER BY m.month_start ;