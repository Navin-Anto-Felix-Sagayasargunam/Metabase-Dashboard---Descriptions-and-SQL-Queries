-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: % of users who engage with goal tracking after setup
-- Card ID: 588
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:25
================================================================================

SELECT
    CASE 
        WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
        ELSE 'SA'
    END AS profile_type,

    -- Numerator: users with active goals
    COUNT(DISTINCT sg.customer_id) AS users_with_goal,

    -- Denominator: all users in goals_v2_v4, including status = 1 and journey_step = 1
    COUNT(DISTINCT all_goals.customer_id) AS total_users,

    -- Percentage of users who engage with goal tracking after setup
    ROUND(
        COUNT(DISTINCT sg.customer_id)::numeric / NULLIF(COUNT(DISTINCT all_goals.customer_id), 0) * 100,
        2
    ) AS pct_users_with_goal

FROM customers_v4 c

-- Join for numerator: active goals only
LEFT JOIN goals_v2_v4 sg
    ON c._id = sg.customer_id
   AND sg.status != 1
   AND sg.journey_step != 1

-- Join for denominator: all goals
LEFT JOIN goals_v2_v4 all_goals
    ON c._id = all_goals.customer_id

-- Join profile table
LEFT JOIN vault_profiles_v4 v
    ON c._id = v.customer_id

WHERE c.creation_date <= CURRENT_DATE
  AND c.is_deleted = 'False'
  [[AND CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profile_type}}]]

GROUP BY 
    CASE 
        WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
        ELSE 'SA'
    END

ORDER BY profile_type;
