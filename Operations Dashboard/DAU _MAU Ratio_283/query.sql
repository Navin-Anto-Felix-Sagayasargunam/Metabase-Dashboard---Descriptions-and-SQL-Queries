-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: DAU /MAU Ratio
-- Card ID: 283
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:57
================================================================================

WITH daily_users AS (
    SELECT 
        CAST(se.last_activity_date AS DATE) AS activity_date,
        COUNT(DISTINCT se.customer_id) AS dau
    FROM sessions_v4 se
    WHERE se.last_activity_date >= COALESCE({{start_date}}, CURRENT_DATE - INTERVAL '2 day')
      AND se.last_activity_date <= COALESCE({{end_date}}, CURRENT_DATE - INTERVAL '1 day')
    GROUP BY CAST(se.last_activity_date AS DATE)
),
monthly_users AS (
    SELECT
        DATE_TRUNC('month', se.last_activity_date)::DATE AS month_start,
        COUNT(DISTINCT se.customer_id) AS mau
    FROM sessions_v4 se
    WHERE se.last_activity_date >= COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months')
      AND se.last_activity_date <= COALESCE({{end_date}}, CURRENT_DATE)
    GROUP BY DATE_TRUNC('month', se.last_activity_date)
)
SELECT
    TO_CHAR(d.activity_date, 'FMDD Mon YYYY') AS activity_date,  -- 👈 formatted as 1 Aug 2025
    d.dau,
    m.mau,
    ROUND((d.dau::numeric / NULLIF(m.mau,0)) * 100, 2) AS dau_mau_ratio_percent
FROM daily_users d
JOIN monthly_users m
    ON DATE_TRUNC('month', d.activity_date) = m.month_start
ORDER BY d.activity_date ASC;
