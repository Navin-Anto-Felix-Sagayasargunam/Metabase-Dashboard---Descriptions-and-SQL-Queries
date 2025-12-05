-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Monthly Active, Linked Users
-- Card ID: 253
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:36
================================================================================

WITH active_customers AS (
    SELECT
        DATE_TRUNC('month', se.last_activity_date) AS month_start,
        COUNT(DISTINCT se.customer_id) AS Active_Users
    FROM sessions_v4 se
    WHERE se.last_activity_date IS NOT NULL
      [[AND se.last_activity_date >= DATE_TRUNC('month', {{start_date}})]]
      [[AND se.last_activity_date <= DATE_TRUNC('month', {{end_date}})]]
    GROUP BY DATE_TRUNC('month', se.last_activity_date)
),
customers_with_session AS (
    SELECT
        DATE_TRUNC('month', CAST(s.last_activity_date AS date)) AS month_start,
        COUNT(DISTINCT s.customer_id) AS Active_Linked_Users
    FROM account_logins_v4 a
    JOIN sessions_v4 s  
        ON s.customer_id = a.customer_id
    WHERE a.refresh_status = 0
      AND a.is_deleted = false
      [[AND CAST(s.last_activity_date AS date) >= DATE_TRUNC('month', {{start_date}})]]
      [[AND CAST(s.last_activity_date AS date) <= DATE_TRUNC('month', {{end_date}})]]
    GROUP BY DATE_TRUNC('month', CAST(s.last_activity_date AS date))
)
SELECT
    ac.month_start,
    TO_CHAR(ac.month_start, 'Mon YYYY') AS month_label,
    ac.Active_Users,
    cs.Active_Linked_Users
FROM active_customers ac
LEFT JOIN customers_with_session cs ON ac.month_start = cs.month_start
ORDER BY ac.month_start;
