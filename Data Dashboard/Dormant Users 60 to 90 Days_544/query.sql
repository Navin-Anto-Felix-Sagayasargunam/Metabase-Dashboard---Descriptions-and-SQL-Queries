-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Dormant Users 60 to 90 Days
-- Card ID: 544
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:43
================================================================================

SELECT 
    TO_CHAR(DATE_TRUNC('month', last_activity_date), 'Mon-YYYY') AS month_label,
    COUNT(*) AS dormant_users_60_90_days
FROM sessions_v4
WHERE last_activity_date >= DATEADD(day, -90, CURRENT_DATE)
  AND last_activity_date < DATEADD(day, -60, CURRENT_DATE)
GROUP BY DATE_TRUNC('month', last_activity_date)
ORDER BY DATE_TRUNC('month', last_activity_date);



