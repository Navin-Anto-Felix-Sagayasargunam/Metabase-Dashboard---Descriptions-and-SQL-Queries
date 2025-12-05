-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Users Uninstalling the App in 1 day
-- Card ID: 582
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:24
================================================================================

WITH daily_uninstalls AS (
    SELECT 
        CAST(c.delete_date AS DATE) AS uninstall_date,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type,
        COUNT(DISTINCT c._id) AS uninstalled_users
    FROM customers_v4 c
    LEFT JOIN vault_profiles_v4 v 
        ON c._id = v.customer_id
    WHERE c.is_deleted = TRUE
      AND c.delete_date IS NOT NULL
      AND c.creation_date IS NOT NULL
      AND EXTRACT(EPOCH FROM (c.delete_date::timestamp - c.creation_date::timestamp)) / 86400 < 1
      AND c.delete_date::date >= (COALESCE({{end_date}}, CURRENT_DATE) - INTERVAL '30 day')
      AND c.delete_date::date < DATE_TRUNC('day', COALESCE({{end_date}}, CURRENT_DATE))  -- only completed days
      [[AND CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profiletype}}]]
    GROUP BY 1, 2
)
SELECT
    TO_CHAR(uninstall_date, 'Mon DD, YYYY') AS uninstall_date,  -- e.g., 'Aug 01, 2025'
    profile_type,
    uninstalled_users,
    ROUND(
        ((uninstalled_users::float - LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY uninstall_date))
         / NULLIF(LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY uninstall_date), 0) * 100),
        2
    ) AS pct_change_vs_prev_day
FROM daily_uninstalls
ORDER BY uninstall_date::date, profile_type;
