-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Active Users Previous 30 days
-- Card ID: 258
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:37
================================================================================

SELECT
--COUNT(distinct customer_id)
    CASE 
        WHEN COUNT(DISTINCT se.customer_id) >= 1000000000 
            THEN TO_CHAR(ROUND(COUNT(DISTINCT se.customer_id) / 1000000000.0, 1), 'FM999999990.0') || 'B'
        WHEN COUNT(DISTINCT se.customer_id) >= 1000000 
            THEN TO_CHAR(ROUND(COUNT(DISTINCT se.customer_id) / 1000000.0, 1), 'FM999999990.0') || 'M'
        WHEN COUNT(DISTINCT se.customer_id) >= 1000 
            THEN TO_CHAR(ROUND(COUNT(DISTINCT se.customer_id) / 1000.0, 1), 'FM999999990.0') || 'K'
        ELSE TO_CHAR(COUNT(DISTINCT se.customer_id), 'FM999999990')
    END AS active_users_last_30d
FROM sessions_v4 se
WHERE 
    ((
    last_activity_date::Date >= TO_CHAR(CURRENT_DATE - INTERVAL '30 day', 'YYYY-MM-DD') --CURRENT_DATE - INTERVAL '30 day'
        AND last_activity_date::date <= CURRENT_DATE 
     --  TO_TIMESTAMP(last_activity_date, 'YYYY-MM-DD HH24:MI:SS.MS')::date >= CURRENT_DATE - INTERVAL '30 day'
      -- AND TO_TIMESTAMP(last_activity_date, 'YYYY-MM-DD HH24:MI:SS.MS')::date <= CURRENT_DATE
    )
    OR
    (
        (
  TO_TIMESTAMP(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS')::date >= TO_CHAR(CURRENT_DATE - INTERVAL '30 day', 'YYYY-MM-DD')
  AND TO_TIMESTAMP(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS')::date <= CURRENT_DATE
    )
   ));