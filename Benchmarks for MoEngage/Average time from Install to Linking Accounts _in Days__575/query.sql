-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Average time from Install to Linking Accounts (in Days)
-- Card ID: 575
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:21
================================================================================

WITH customer_profiles AS (
    SELECT 
        c._id,
        c.creation_date,
        c.first_account_link_date,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type
    FROM customers_v4 c
    LEFT JOIN vault_profiles_v4 v
        ON c._id = v.customer_id
    WHERE c.first_account_link_date IS NOT NULL
      AND c.is_deleted = FALSE
),
monthly_avg AS (
    SELECT 
        DATE_TRUNC('month', creation_date) AS month_start,
        profile_type,
        ROUND(
            AVG(EXTRACT(EPOCH FROM (first_account_link_date::timestamp - creation_date::timestamp)) / 86400), 
            2
        ) AS avg_days_to_first_link,
        COUNT(*) AS users_included
    FROM customer_profiles
    WHERE creation_date::date >= COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 month')
      AND creation_date::date <= COALESCE({{end_date}}, CURRENT_DATE)
      AND DATE_TRUNC('month', creation_date) < DATE_TRUNC('month', CURRENT_DATE)  -- completed months
      [[AND profile_type = {{profile_type}}]] -- optional Metabase filter
    GROUP BY DATE_TRUNC('month', creation_date), profile_type
)
SELECT
    month_start,  -- use this as the X-axis in Metabase
    profile_type,
    avg_days_to_first_link, -- main trend value
    LAG(avg_days_to_first_link) OVER (PARTITION BY profile_type ORDER BY month_start) AS prev_month_avg,
    ROUND(
        ((avg_days_to_first_link - LAG(avg_days_to_first_link) OVER (PARTITION BY profile_type ORDER BY month_start))
         / NULLIF(LAG(avg_days_to_first_link) OVER (PARTITION BY profile_type ORDER BY month_start), 0) * 100), 
        2
    ) AS pct_change_vs_prev_month,
    users_included
FROM monthly_avg
ORDER BY month_start, profile_type;
