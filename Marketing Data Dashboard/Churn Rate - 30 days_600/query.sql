-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Churn Rate - 30 days
-- Card ID: 600
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:43
================================================================================

WITH months AS (
    -- Select all months where the next month is fully within the filter range
    SELECT DISTINCT DATE_TRUNC('month', last_activity_date) AS month_start
    FROM sessions_v4
    WHERE last_activity_date BETWEEN {{start_date}} AND {{end_date}}
      AND DATEADD(month, 1, DATE_TRUNC('month', last_activity_date)) <= {{end_date}}
),

user_start_period AS (
    SELECT m.month_start, usp.customer_id
    FROM months m
    JOIN sessions_v4 usp
      ON usp.last_activity_date >= m.month_start
     AND usp.last_activity_date < DATEADD(month, 1, m.month_start)
    GROUP BY m.month_start, usp.customer_id
),

active_next_1_month AS (
    SELECT m.month_start, a1.customer_id
    FROM months m
    JOIN sessions_v4 a1
      ON a1.last_activity_date >= DATEADD(month, 1, m.month_start)
     AND a1.last_activity_date < DATEADD(month, 2, m.month_start)  -- next 1 month
    GROUP BY m.month_start, a1.customer_id
),

final_data AS (
    SELECT
        usp.month_start,
        usp.customer_id AS start_month_user,
        a1.customer_id AS next_1_month_user
    FROM user_start_period usp
    LEFT JOIN active_next_1_month a1
       ON usp.customer_id = a1.customer_id
      AND usp.month_start = a1.month_start
)

SELECT
    TO_CHAR(month_start, 'Mon YYYY') AS month,
    COUNT(start_month_user) AS total_active_users_start_month,
    COUNT(next_1_month_user) AS active_next_1_month,
    ROUND(
        ((COUNT(start_month_user) - COUNT(next_1_month_user))::numeric
         / COUNT(start_month_user)) * 100, 2
    ) AS churn_next_1_month
FROM final_data
GROUP BY month_start
ORDER BY month_start;
