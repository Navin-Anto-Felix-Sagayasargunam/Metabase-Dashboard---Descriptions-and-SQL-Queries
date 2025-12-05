-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: % of users uninstalling within: 7 day
-- Card ID: 585
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:23
================================================================================

WITH RECURSIVE completed_weeks(week_start) AS (
    -- anchor: 10 weeks ago
    SELECT DATEADD(week, -10, DATE_TRUNC('week', COALESCE({{end_date}}, CURRENT_DATE))) AS week_start
    UNION ALL
    -- recursive: add 1 week at a time
    SELECT DATEADD(week, 1, week_start)
    FROM completed_weeks
    WHERE DATEADD(week, 1, week_start) < DATE_TRUNC('week', COALESCE({{end_date}}, CURRENT_DATE))  -- only completed weeks
),
weekly_uninstalls AS (
    SELECT
        cw.week_start,
        DATEADD(day, 6, cw.week_start) AS week_end,
        TO_CHAR(cw.week_start, 'Mon DD') || ' - ' || TO_CHAR(DATEADD(day,6,cw.week_start), 'Mon DD, YYYY') AS week_label,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type,
        COUNT(DISTINCT c._id) AS uninstalled_users
    FROM completed_weeks cw
    LEFT JOIN customers_v4 c
        ON c.is_deleted = TRUE
        AND c.delete_date::date BETWEEN cw.week_start AND DATEADD(day,6,cw.week_start)
        AND c.creation_date IS NOT NULL
        AND EXTRACT(EPOCH FROM (c.delete_date::timestamp - c.creation_date::timestamp)) / 86400 < 7
    LEFT JOIN vault_profiles_v4 v
        ON c._id = v.customer_id
    [[WHERE CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profiletype}}]]
    GROUP BY cw.week_start, profile_type
)
SELECT
    week_start,
    week_label,
    profile_type,
    uninstalled_users,
    LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY week_start) AS prev_week_uninstalls,
    ROUND(
        ((uninstalled_users::float - LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY week_start))
         / NULLIF(LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY week_start),0) * 100),
        2
    ) AS pct_change_vs_prev_week
FROM weekly_uninstalls
ORDER BY profile_type, week_start;
