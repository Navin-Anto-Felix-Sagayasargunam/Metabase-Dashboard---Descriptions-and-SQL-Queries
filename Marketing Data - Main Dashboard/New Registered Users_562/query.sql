-- Dashboard: Marketing Data - Main Dashboard
-- Dashboard ID: 67
-- Chart: New Registered Users
-- Card ID: 562
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:26
================================================================================

WITH date_logic AS (
    SELECT 
        COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months')::date AS start_date,
        COALESCE({{end_date}}, CURRENT_DATE)::date AS end_date,
        CASE 
            -- If end_date is the last day of the month → compare current vs previous
            WHEN COALESCE({{end_date}}, CURRENT_DATE)::date 
                 = (DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)::date) 
                    + INTERVAL '1 month - 1 day')
            THEN DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)::date)
            -- Otherwise → compare previous two full months
            ELSE DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)::date) - INTERVAL '1 month'
        END AS month1_start,
        CASE 
            WHEN COALESCE({{end_date}}, CURRENT_DATE)::date 
                 = (DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)::date) 
                    + INTERVAL '1 month - 1 day')
            THEN DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)::date) - INTERVAL '1 month'
            ELSE DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)::date) - INTERVAL '2 month'
        END AS month2_start
),
filtered_customers AS (
    SELECT 
        c._id,
        DATE_TRUNC('month', c.creation_date)::date AS month_start,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type
    FROM customers_v4 c
    LEFT JOIN vault_profiles_v4 v 
        ON c._id = v.customer_id
    GROUP BY c._id, v._t, c.creation_date
),
deduped_customers AS (
    SELECT DISTINCT _id, month_start, profile_type
    FROM filtered_customers
),
monthly_counts AS (
    SELECT
        dc.month_start,
        COUNT(*) AS user_count
    FROM deduped_customers dc
    CROSS JOIN date_logic
    WHERE dc.month_start >= date_logic.start_date
      AND dc.month_start IN (date_logic.month1_start, date_logic.month2_start)
      [[AND dc.profile_type = {{profile_type}}]] -- optional Metabase filter
    GROUP BY dc.month_start
)
SELECT
    mc.month_start,
    mc.user_count,
    ROUND(
        (
            (mc.user_count::float - LAG(mc.user_count) OVER (ORDER BY mc.month_start)) 
            / NULLIF(LAG(mc.user_count) OVER (ORDER BY mc.month_start), 0) * 100
        ), 2
    ) AS pct_change_vs_prev_month
FROM monthly_counts mc
ORDER BY mc.month_start;
