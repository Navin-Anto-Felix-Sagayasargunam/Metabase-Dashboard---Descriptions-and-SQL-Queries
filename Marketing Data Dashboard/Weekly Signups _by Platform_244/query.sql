-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Weekly Signups ,by Platform 
-- Card ID: 244
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:34
================================================================================

WITH weekly AS (
    SELECT
        DATE_TRUNC('week', creation_date)::date AS week_start,
        _id AS customer_id
    FROM customers_v4
    WHERE creation_date >= COALESCE({{start_date}}, GETDATE() - INTERVAL '34 weeks')
      AND creation_date <= COALESCE({{end_date}}, GETDATE())
)
SELECT
    TO_CHAR(wk.week_start, 'DD Mon YYYY') || ' to ' ||
    TO_CHAR(wk.week_start + INTERVAL '6 days', 'DD Mon YYYY') AS week_range,
    wk.week_start,
    (wk.week_start + INTERVAL '6 days')::date AS week_end,
    sess.n_Parsed_Plat,
    COUNT(distinct sess.customer_id) AS Customers_Count
FROM weekly wk
LEFT JOIN (
    SELECT  
        CASE 
            WHEN parsed_platform LIKE '%Flutter%' 
                THEN Platform_information_device_type 
            ELSE parsed_platform 
        END AS n_Parsed_Plat,
        customer_id
    FROM sessions_v4
    WHERE 
        1=1
      AND ( {{platform}} IN ({{platform}}) )
) sess
    ON wk.customer_id = sess.customer_id
GROUP BY wk.week_start, sess.n_Parsed_Plat
HAVING COUNT(sess.customer_id) > 0
ORDER BY wk.week_start;
