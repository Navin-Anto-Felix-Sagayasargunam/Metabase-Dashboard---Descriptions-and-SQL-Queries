-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: DAU,MAU Ratio with stickiness
-- Card ID: 576
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:21
================================================================================

WITH daily_active AS (
    -- Count of unique active users per day
    SELECT
        DATE_TRUNC('day', last_activity_date) AS day_start,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type,
        COUNT(DISTINCT se.customer_id) AS dau
    FROM sessions_v4 se
    LEFT JOIN vault_profiles_v4 v
        ON se.customer_id = v.customer_id
    WHERE se.last_activity_date::date >= COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months')
	AND se.last_activity_date::date < DATE_TRUNC('month', CURRENT_DATE)
      AND se.last_activity_date::date <= COALESCE({{end_date}}, CURRENT_DATE)
      [[AND CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profile_type}}]]
    GROUP BY DATE_TRUNC('day', last_activity_date), profile_type
),
monthly_active AS (
    -- Count of unique users active per month
    SELECT
        DATE_TRUNC('month', se.last_activity_date) AS month_start,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type,
        COUNT(DISTINCT se.customer_id) AS mau
    FROM sessions_v4 se
    LEFT JOIN vault_profiles_v4 v
        ON se.customer_id = v.customer_id
    WHERE se.last_activity_date::date >= COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months')
      AND se.last_activity_date::date <= COALESCE({{end_date}}, CURRENT_DATE)
      [[AND CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profile_type}}]]
    GROUP BY DATE_TRUNC('month', se.last_activity_date), profile_type
),
monthly_dau AS (
    -- Average DAU per month per profile
    SELECT
        DATE_TRUNC('month', day_start) AS month_start,
        profile_type,
        ROUND(AVG(dau)::numeric, 2) AS avg_dau
    FROM daily_active
    GROUP BY DATE_TRUNC('month', day_start), profile_type
)
SELECT
    m.month_start,
    TO_CHAR(m.month_start, 'Mon YYYY') AS month_label,
    m.profile_type,
    m.avg_dau AS avg_daily_active_users,
    ma.mau AS monthly_active_users,
    ROUND((m.avg_dau::numeric / ma.mau) * 100, 2) AS dau_mau_ratio_percent
FROM monthly_dau m
JOIN monthly_active ma
    ON m.month_start = ma.month_start
    AND m.profile_type = ma.profile_type
ORDER BY m.month_start, m.profile_type;
