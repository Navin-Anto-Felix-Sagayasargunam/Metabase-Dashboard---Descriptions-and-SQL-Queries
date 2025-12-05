-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Dormant users 30 days
-- Card ID: 144
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:22
================================================================================

SELECT
   -- TO_CHAR(last_activity_date, 'Mon-YYYY') AS month_label,
    COUNT(distinct customer_id) AS dormant_users_0_30_days
FROM sessions_v4
WHERE last_activity_date < CURRENT_DATE - INTERVAL '30 day'
  -- OR last_activity_date IS NULL  -- include users who never logged in
--GROUP BY month_label
--ORDER BY MIN(last_activity_date);
