-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Number of users uninstalling within: 7  day
-- Card ID: 584
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:23
================================================================================

WITH RECURSIVE last_weeks(week_start, week_end, week_number) AS (
    -- Anchor: most recent completed week (week ends Sunday)
    SELECT 
        DATE_TRUNC('week', COALESCE({{end_date}}, CURRENT_DATE)) - INTERVAL '1 week' AS week_start,
        DATE_TRUNC('week', COALESCE({{end_date}}, CURRENT_DATE)) - INTERVAL '1 day' AS week_end,
        1 AS week_number
    UNION ALL
    -- Recursive: go back 1 week at a time
    SELECT 
        week_start - INTERVAL '1 week',
        week_end - INTERVAL '1 week',
        week_number + 1
    FROM last_weeks
    WHERE week_number < 10
),
weekly_uninstalls AS (
    SELECT
        TO_CHAR(lw.week_start, 'Mon DD') || ' - ' || TO_CHAR(lw.week_end, 'Mon DD, YYYY') AS week_label,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type,
        COUNT(DISTINCT c._id) AS uninstalled_users
    FROM last_weeks lw
    LEFT JOIN customers_v4 c
        ON c.is_deleted = TRUE
        AND c.delete_date::date BETWEEN lw.week_start AND lw.week_end
        AND c.creation_date IS NOT NULL
        AND EXTRACT(EPOCH FROM (c.delete_date::timestamp - c.creation_date::timestamp)) / 86400 < 7  -- uninstalled within 7 days
    LEFT JOIN vault_profiles_v4 v
        ON c._id = v.customer_id
    [[WHERE CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profiletype}}]]
    GROUP BY lw.week_start, lw.week_end, profile_type
)
SELECT
    week_label,
    profile_type,
    uninstalled_users,
    ROUND(
        ((uninstalled_users::float - LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY week_label))
         / NULLIF(LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY week_label), 0) * 100),
        2
    ) AS pct_change_vs_prev_week
FROM weekly_uninstalls
ORDER BY profile_type, week_label;
