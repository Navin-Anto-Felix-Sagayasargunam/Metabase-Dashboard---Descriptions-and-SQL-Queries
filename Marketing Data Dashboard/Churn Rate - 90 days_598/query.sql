-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Churn Rate - 90 days
-- Card ID: 598
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:45
================================================================================

WITH months AS (
    SELECT DISTINCT DATE_TRUNC('month', last_activity_date) AS month_start
    FROM sessions_v4
    WHERE last_activity_date BETWEEN {{start_date}} AND {{end_date}}
      -- only include months where next 3 months exist within end_date
      AND DATEADD(month, 3, DATE_TRUNC('month', last_activity_date)) <= {{end_date}}
),

user_start_period AS (
    SELECT m.month_start, usp.customer_id
    FROM months m
    JOIN sessions_v4 usp
      ON usp.last_activity_date >= m.month_start
     AND usp.last_activity_date < DATEADD(month, 1, m.month_start)
    GROUP BY m.month_start, usp.customer_id
),

active_next_3_months AS (
    SELECT m.month_start, an3.customer_id
    FROM months m
    JOIN sessions_v4 an3
      ON an3.last_activity_date >= DATEADD(month, 1, m.month_start)
     AND an3.last_activity_date < DATEADD(month, 4, m.month_start)
    GROUP BY m.month_start, an3.customer_id
),

final_data AS (
    SELECT
        usp.month_start,
        usp.customer_id AS start_month_user,
        an3.customer_id AS next_3_months_user
    FROM user_start_period usp
    LEFT JOIN active_next_3_months an3
       ON usp.customer_id = an3.customer_id
      AND usp.month_start = an3.month_start
)

SELECT
    TO_CHAR(month_start, 'Mon YYYY') AS month,
    COUNT(start_month_user) AS total_users_start_month,
    COUNT(next_3_months_user) AS active_next_3_months,
    ROUND(
        ((COUNT(start_month_user) - COUNT(next_3_months_user))::numeric
         / COUNT(start_month_user)) * 100, 2
    ) AS churn_next_3_months
FROM final_data
GROUP BY month_start
ORDER BY month_start;
