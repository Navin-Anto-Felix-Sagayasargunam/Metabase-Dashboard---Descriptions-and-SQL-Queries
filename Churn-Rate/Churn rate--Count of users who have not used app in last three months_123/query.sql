-- Dashboard: Churn-Rate 
-- Dashboard ID: 25
-- Chart: Churn rate--Count of users who have not used app in last three months
-- Card ID: 123
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:32
================================================================================

select count(distinct customer_id)  from customers 
where date(last_activity_date) < '2025-05-05'