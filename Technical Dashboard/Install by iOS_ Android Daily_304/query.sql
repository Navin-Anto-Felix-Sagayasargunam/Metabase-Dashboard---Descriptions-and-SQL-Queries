-- Dashboard: Technical Dashboard
-- Dashboard ID: 57
-- Chart: Install by iOS, Android Daily
-- Card ID: 304
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:38
================================================================================

SELECT
    DATE(creation_date) AS activity_date,
    TO_CHAR(DATE(creation_date), 'DD Mon YYYY') AS activity_date_label,
    CASE
        WHEN LOWER(registered_on_os_version) LIKE 'ios%' THEN 'iOS'
        WHEN LOWER(registered_on_os_version) LIKE 'android%' THEN 'Android'
        WHEN registered_on_os_version = 'Android' THEN 'Android'
    END AS device_type,
    COUNT(*) AS user_count
FROM customers_v4
WHERE DATE(creation_date) BETWEEN 
        COALESCE({{start_date}}, CURRENT_DATE - interval '7 days') 
        AND COALESCE({{end_date}}, CURRENT_DATE)
  AND (
        LOWER(registered_on_os_version) LIKE 'ios%' 
        OR LOWER(registered_on_os_version) LIKE 'android%' 
        OR registered_on_os_version = 'Android'
      )
GROUP BY DATE(creation_date), device_type
ORDER BY DATE(creation_date), device_type;
