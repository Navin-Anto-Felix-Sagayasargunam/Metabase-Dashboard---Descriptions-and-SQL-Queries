-- Dashboard: Marketing Data - Main Dashboard
-- Dashboard ID: 67
-- Chart: New Accounts Linked by Month
-- Card ID: 566
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:27
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
        DATE_TRUNC('month', c.first_account_link_date::timestamp)::date AS month_start,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type
    FROM customers_v4 c
    LEFT JOIN vault_profiles_v4 v
        ON c._id = v.customer_id
    WHERE c.first_account_link_date IS NOT NULL
      AND c.is_deleted = 'False'
      [[AND CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profile_type}}]]  -- optional Metabase filter
),
deduped_customers AS (
    SELECT DISTINCT _id, month_start, profile_type
    FROM filtered_customers
),
monthly_counts AS (
    SELECT
        dc.month_start,
        dc.profile_type,
        COUNT(*) AS total_customers
    FROM deduped_customers dc
    CROSS JOIN date_logic
    WHERE dc.month_start >= date_logic.start_date
      AND dc.month_start IN (date_logic.month1_start, date_logic.month2_start)
    GROUP BY dc.month_start, dc.profile_type
)
SELECT
    mc.month_start,
    TO_CHAR(mc.month_start, 'Mon YYYY') AS month_label,
    mc.profile_type,
    mc.total_customers,
    LAG(mc.total_customers) OVER (PARTITION BY mc.profile_type ORDER BY mc.month_start) AS prev_month_customers,
    ROUND(
        ((mc.total_customers::float - LAG(mc.total_customers) OVER (PARTITION BY mc.profile_type ORDER BY mc.month_start))
         / NULLIF(LAG(mc.total_customers) OVER (PARTITION BY mc.profile_type ORDER BY mc.month_start), 0) * 100), 2
    ) AS pct_change_vs_prev_month
FROM monthly_counts mc
ORDER BY mc.profile_type, mc.month_start;
