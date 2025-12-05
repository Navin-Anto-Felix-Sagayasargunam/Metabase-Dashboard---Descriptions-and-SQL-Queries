-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Number of users uninstalling within 30 days
-- Card ID: 586
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:24
================================================================================

WITH last_two_months AS (
    -- get the first day of the last 2 completed months within Metabase date range
    SELECT DATE_TRUNC('month', DATEADD(month, -1, DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)))) AS month_start
    UNION ALL
    SELECT DATE_TRUNC('month', DATEADD(month, -2, DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)))) AS month_start
),
monthly_uninstalls AS (
    SELECT
        m.month_start,
        DATEADD(month, 1, m.month_start) - INTERVAL '1 day' AS month_end,
        TO_CHAR(m.month_start, 'Mon YYYY') AS month_label,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type,
        COUNT(DISTINCT c._id) AS uninstalled_users
    FROM last_two_months m
    LEFT JOIN customers_v4 c
        ON c.is_deleted = TRUE
        AND c.delete_date::date BETWEEN m.month_start AND (DATEADD(month, 1, m.month_start) - INTERVAL '1 day')
        AND EXTRACT(EPOCH FROM (c.delete_date::timestamp - c.creation_date::timestamp)) / 86400 < 30
        AND c.delete_date::date BETWEEN COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 month')
                                   AND COALESCE({{end_date}}, CURRENT_DATE)
    LEFT JOIN vault_profiles_v4 v
        ON c._id = v.customer_id
    [[WHERE CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profiletype}}]]
    GROUP BY m.month_start, profile_type
)
SELECT
    month_start,
    month_label,
    profile_type,
    uninstalled_users,
    LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY month_start) AS prev_month_uninstalls,
    ROUND(
        ((uninstalled_users::float - LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY month_start))
         / NULLIF(LAG(uninstalled_users) OVER (PARTITION BY profile_type ORDER BY month_start),0) * 100),
        2
    ) AS pct_change_vs_prev_month
FROM monthly_uninstalls
ORDER BY profile_type, month_start;
