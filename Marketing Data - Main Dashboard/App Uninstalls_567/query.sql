-- Dashboard: Marketing Data - Main Dashboard
-- Dashboard ID: 67
-- Chart: App Uninstalls
-- Card ID: 567
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:27
================================================================================

WITH month_window AS (
    SELECT
        -- Start at first day of start month
        DATE_TRUNC('month', {{start_date}}::date) AS start_month,
        -- End at the last fully completed month
        CASE 
            WHEN DATE_TRUNC('month', {{end_date}}::date) = DATE_TRUNC('month', CURRENT_DATE)
                 THEN DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 day'
            ELSE (DATE_TRUNC('month', {{end_date}}::date) + INTERVAL '1 month - 1 day')
        END AS end_date
),

inactive_users AS (
    SELECT
        DATE_TRUNC('month', c.delete_date::timestamp) AS month_start,
        TO_CHAR(DATE_TRUNC('month', c.delete_date::timestamp), 'Mon YYYY') AS month_label,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type,
        COUNT(DISTINCT c._id) AS total_inactive_users
    FROM customers_v4 c
    LEFT JOIN vault_profiles_v4 v
        ON c._id = v.customer_id
    CROSS JOIN month_window mw
    WHERE c.delete_date IS NOT NULL
      AND c.is_deleted = 'True'
      -- Include only users deleted within completed months
      AND c.delete_date::date BETWEEN mw.start_month AND mw.end_date
      [[AND CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
          END = {{profile_type}}]]
    GROUP BY 1, 2, 3
)

SELECT
    iu.month_start,
    iu.month_label,
    iu.profile_type,
    iu.total_inactive_users,
    LAG(iu.total_inactive_users) OVER (PARTITION BY iu.profile_type ORDER BY iu.month_start) AS prev_month_inactive,
    ROUND(
        ((iu.total_inactive_users::float - 
          LAG(iu.total_inactive_users) OVER (PARTITION BY iu.profile_type ORDER BY iu.month_start))
         / NULLIF(LAG(iu.total_inactive_users) OVER (PARTITION BY iu.profile_type ORDER BY iu.month_start), 0) * 100), 2
    ) AS pct_change_vs_prev_month
FROM inactive_users iu
ORDER BY iu.month_start, iu.profile_type;
