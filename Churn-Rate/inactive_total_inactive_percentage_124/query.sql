-- Dashboard: Churn-Rate 
-- Dashboard ID: 25
-- Chart: inactive,total,inactive_percentage
-- Card ID: 124
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:32
================================================================================

WITH Total_Users AS (
    SELECT COUNT(DISTINCT customer_id) AS Total_Users
    FROM customers
    WHERE is_deleted = FALSE
),
Inactive_Users AS (
    SELECT COUNT(DISTINCT customer_id) AS Inactive_Users
    FROM customers
    WHERE is_deleted = FALSE
      AND DATE(last_activity_date) < '2025-05-05'
)
SELECT 
    Inactive_Users.Inactive_Users,
    Total_Users.Total_Users,
    ROUND(Inactive_Users.Inactive_Users::decimal / Total_Users.Total_Users * 100, 2) AS Inactive_Percentage
FROM Total_Users, Inactive_Users;
