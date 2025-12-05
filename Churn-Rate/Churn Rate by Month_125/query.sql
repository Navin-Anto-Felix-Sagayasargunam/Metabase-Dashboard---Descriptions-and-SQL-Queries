-- Dashboard: Churn-Rate 
-- Dashboard ID: 25
-- Chart: Churn Rate by Month
-- Card ID: 125
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:33
================================================================================

WITH monthly_activity AS (
    SELECT
        DATE_TRUNC('month', last_activity_date) AS month,
        COUNT(DISTINCT customer_id) AS active_users
    FROM customers
    WHERE is_deleted = FALSE
      [[AND last_activity_date >= DATE_TRUNC('month', {{start_date}})]]
      [[AND last_activity_date <= DATE_TRUNC('month', {{end_date}})]]
    GROUP BY DATE_TRUNC('month', last_activity_date)
),
total AS (
    SELECT COUNT(DISTINCT customer_id) AS total 
    FROM customers 
    WHERE is_deleted = FALSE
)
SELECT
    TO_CHAR(ma.month, 'Mon YYYY') AS month,
    (t.total - ma.active_users)::float / t.total * 100 AS inactive_percentage
FROM monthly_activity ma
CROSS JOIN total t
ORDER BY ma.month;
