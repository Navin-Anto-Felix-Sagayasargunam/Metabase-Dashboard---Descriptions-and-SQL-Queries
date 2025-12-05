-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Active Linked Users - Previous 90 days
-- Card ID: 229
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:32
================================================================================

SELECT
    CASE 
        WHEN COUNT(DISTINCT s.customer_id) >= 1000000000 
            THEN TO_CHAR(ROUND(COUNT(DISTINCT s.customer_id) / 1000000000.0, 1), 'FM999999990.0') || 'B'
        WHEN COUNT(DISTINCT s.customer_id) >= 1000000 
            THEN TO_CHAR(ROUND(COUNT(DISTINCT s.customer_id) / 1000000.0, 1), 'FM999999990.0') || 'M'
        WHEN COUNT(DISTINCT s.customer_id) >= 1000 
            THEN TO_CHAR(ROUND(COUNT(DISTINCT s.customer_id) / 1000.0, 1), 'FM999999990.0') || 'K'
        ELSE TO_CHAR(COUNT(DISTINCT s.customer_id), 'FM999999990')
    END AS active_linked_users_90d
FROM sessions_v4 AS s
JOIN account_logins_v4 AS a
  ON s.customer_id = a.customer_id
WHERE 
    ((
    s.last_activity_date::Date >= TO_CHAR(CURRENT_DATE - INTERVAL '90 day', 'YYYY-MM-DD') --CURRENT_DATE - INTERVAL '30 day'
        AND s.last_activity_date::date <= CURRENT_DATE 
     --  TO_TIMESTAMP(last_activity_date, 'YYYY-MM-DD HH24:MI:SS.MS')::date >= CURRENT_DATE - INTERVAL '30 day'
      -- AND TO_TIMESTAMP(last_activity_date, 'YYYY-MM-DD HH24:MI:SS.MS')::date <= CURRENT_DATE
    )
    OR
    (
        (
  TO_TIMESTAMP(s.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS')::date >= TO_CHAR(CURRENT_DATE - INTERVAL '90 day', 'YYYY-MM-DD')
  AND TO_TIMESTAMP(s.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS')::date <= CURRENT_DATE
    )
   ))
  AND (a.is_deleted IS NULL OR a.is_deleted = FALSE)
  AND a.refresh_status = 0;
