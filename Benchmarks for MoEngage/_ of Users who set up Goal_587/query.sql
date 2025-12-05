-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: % of Users who set up Goal
-- Card ID: 587
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:24
================================================================================

SELECT
    CASE 
        WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
        ELSE 'SA'
    END AS profile_type,
    COUNT(DISTINCT sg.customer_id) AS users_with_goal,
    COUNT(DISTINCT c._id) AS total_users,
    ROUND(
        COUNT(DISTINCT sg.customer_id)::numeric / COUNT(DISTINCT c._id) * 100,
        2
    ) AS pct_users_with_goal
FROM customers_v4 c
LEFT JOIN goals_v2_v4 sg
    ON c._id = sg.customer_id
LEFT JOIN vault_profiles_v4 v
    ON c._id = v.customer_id
WHERE c.creation_date <= CURRENT_DATE
  AND c.is_deleted = 'False'
  AND ({{profile_type}} IS NULL OR 
       CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profile_type}})
GROUP BY 
    CASE 
        WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
        ELSE 'SA'
    END
ORDER BY profile_type;