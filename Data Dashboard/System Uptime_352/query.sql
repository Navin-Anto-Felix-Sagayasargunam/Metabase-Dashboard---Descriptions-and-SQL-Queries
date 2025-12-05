-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: System Uptime
-- Card ID: 352
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:44
================================================================================

SELECT
    TO_CHAR(DATE(datehour), 'Mon DD, YYYY') AS activity_date,
    100 - AVG(crashaffectedusers) AS system_uptime_percent
FROM public.google_analytics_crashdetails
WHERE datehour::date BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
GROUP BY DATE(datehour)
ORDER BY DATE(datehour)