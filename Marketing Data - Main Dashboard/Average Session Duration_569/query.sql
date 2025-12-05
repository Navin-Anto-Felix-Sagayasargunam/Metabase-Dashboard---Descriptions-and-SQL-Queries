-- Dashboard: Marketing Data - Main Dashboard
-- Dashboard ID: 67
-- Chart: Average Session Duration
-- Card ID: 569
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:28
================================================================================

WITH monthly_sessions AS (
    SELECT
        DATE_TRUNC('month', date) AS month_start,
        ROUND(SUM(averagesessionduration * sessions) / NULLIF(SUM(sessions), 0), 2) AS avg_session_duration_seconds,
        ROUND((SUM(averagesessionduration * sessions) / NULLIF(SUM(sessions), 0)) / 60, 2) AS avg_session_duration_minutes
    FROM google_analytics_sessionsduration
    WHERE date::date >= COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 month')
      AND date::date <= COALESCE({{end_date}}, CURRENT_DATE)
      AND date::date <= DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)) + INTERVAL '1 month - 1 day'  -- include last day of month
    GROUP BY DATE_TRUNC('month', date)
)
SELECT
    month_start,
    TO_CHAR(month_start, 'Mon YYYY') AS month_label,
    avg_session_duration_seconds,
    avg_session_duration_minutes,
    LAG(avg_session_duration_minutes) OVER (ORDER BY month_start) AS prev_month_duration,
    ROUND(
        ((avg_session_duration_minutes - LAG(avg_session_duration_minutes) OVER (ORDER BY month_start))
         / NULLIF(LAG(avg_session_duration_minutes) OVER (ORDER BY month_start), 0) * 100), 2
    ) AS pct_change_vs_prev_month
FROM monthly_sessions
ORDER BY month_start;
