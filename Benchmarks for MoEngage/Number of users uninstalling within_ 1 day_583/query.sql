-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Number of users uninstalling within: 1 day
-- Card ID: 583
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:22
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
      -- Uninstalled within 1 day of installation
      AND EXTRACT(EPOCH FROM (c.delete_date::timestamp - c.creation_date::timestamp)) / 86400 < 1
      -- Last 30 days based on selected end date
      AND c.delete_date::date >= (COALESCE({{end_date}}, CURRENT_DATE) - INTERVAL '30 day')
      -- Exclude current day (only completed days)
      AND c.delete_date::date < DATE_TRUNC('day', COALESCE({{end_date}}, CURRENT_DATE))
      [[AND CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profiletype}}]]
    GROUP BY 1, 2
)
SELECT
    uninstall_date,  -- keep as date for trend visualization
    profile_type,
    uninstalled_users,
    ROUND(
        ((uninstalled_users::float - LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY uninstall_date))
         / NULLIF(LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY uninstall_date), 0) * 100),
        2
    ) AS pct_change_vs_prev_day
FROM daily_uninstalls
ORDER BY uninstall_date, profile_type;
