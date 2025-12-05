-- Dashboard: Technical Dashboard
-- Dashboard ID: 57
-- Chart: App Installation Splitup by OS
-- Card ID: 303
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:39
================================================================================

SELECT
    CASE
        WHEN LOWER(registered_on_os_version) LIKE 'ios%' THEN 'iOS'
        WHEN LOWER(registered_on_os_version) LIKE 'android %' THEN 'Android'
        WHEN registered_on_os_version LIKE 'Android' THEN 'Android'
        WHEN registered_on_os_version LIKE 'Ubuntu' THEN 'Ubuntu'
        WHEN registered_on_os_version LIKE 'Fedora' THEN 'Fedora'
        WHEN registered_on_os_version LIKE 'Firefox OS' THEN 'Firefox OS'
        WHEN LOWER(registered_on_os_version) LIKE 'mac os x%' THEN 'Mac OS X'
        WHEN LOWER(registered_on_os_version) LIKE 'windows%' THEN 'Windows'
        WHEN LOWER(registered_on_os_version) LIKE 'linux%' THEN 'Linux'
        WHEN LOWER(registered_on_os_version) LIKE 'chrome%' THEN 'Chrome'
        ELSE 'Other'
    END AS Device_type,
    COUNT(*) AS installed_count
FROM customers_v4
WHERE DATE(creation_date) >= '2020-01-01'
GROUP BY Device_type
ORDER BY installed_count DESC;