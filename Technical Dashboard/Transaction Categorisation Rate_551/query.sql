-- Dashboard: Technical Dashboard
-- Dashboard ID: 57
-- Chart: Transaction Categorisation Rate
-- Card ID: 551
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:39
================================================================================

SELECT
    TO_CHAR(TO_DATE(pay_period::text, 'YYYYMM'), 'Mon YYYY') AS pay_period_label,
    SUM(CASE WHEN category_id IS NOT NULL THEN 1 ELSE 0 END) AS categorized_count,
    SUM(CASE WHEN category_id IS NULL THEN 1 ELSE 0 END) AS uncategorized_count,
    COUNT(*) AS total_count,
    -- Transaction Categorization Rate (%)
    ROUND(
        (SUM(CASE WHEN category_id IS NOT NULL THEN 1 ELSE 0 END)::numeric / COUNT(*)::numeric) * 100,
        2
    ) AS categorization_rate_pct
FROM activities_v4
WHERE pay_period::int BETWEEN 
      TO_CHAR(DATE_TRUNC('month', {{start_date}}), 'YYYYMM')::int
      AND TO_CHAR(DATE_TRUNC('month', {{end_date}}), 'YYYYMM')::int
GROUP BY pay_period
ORDER BY pay_period::int;
