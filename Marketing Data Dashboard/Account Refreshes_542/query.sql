-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Account Refreshes
-- Card ID: 542
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:42
================================================================================

SELECT 
    TO_CHAR(DATE_TRUNC('month', last_updated::timestamp), 'Mon YYYY') AS month_year,
    CASE 
        WHEN refresh_trigger = 'autoAccountUpdate' THEN 'Yes'
        ELSE 'No'
    END AS refreshed,
    COUNT(*) AS refresh_count
FROM account_login_refreshes_v4
WHERE is_deleted = 'False'
  [[AND last_updated::timestamp >= {{start_date}}]]
  [[AND last_updated::timestamp <= LEAST({{end_date}}, (DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 day'))]]
GROUP BY 
    TO_CHAR(DATE_TRUNC('month', last_updated::timestamp), 'Mon YYYY'),
    CASE 
        WHEN refresh_trigger = 'autoAccountUpdate' THEN 'Yes'
        ELSE 'No'
    END
ORDER BY MIN(last_updated::timestamp);
