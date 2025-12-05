-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Dormant users between 60 and 90 days
-- Card ID: 145
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:22
================================================================================

SELECT
    COUNT(DISTINCT customer_id) AS dormant_users_60_90_days
FROM sessions_v4
WHERE last_activity_date < CURRENT_DATE - INTERVAL '60 day'
  AND last_activity_date >= CURRENT_DATE - INTERVAL '90 day';

