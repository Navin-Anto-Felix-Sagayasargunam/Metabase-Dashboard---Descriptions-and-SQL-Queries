-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Conversion funnel: Installs → Activations → KYC completions → First transaction
-- Card ID: 592
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:25
================================================================================

-- Determine start and end of the target period
WITH target_period AS (
    SELECT
        DATE_TRUNC('month', COALESCE({{start_date}}, CURRENT_DATE))::date AS period_start,
        -- If end_date is in current month, use last day of previous month
        CASE
            WHEN DATE_TRUNC('month', COALESCE({{end_date}}, CURRENT_DATE)) = DATE_TRUNC('month', CURRENT_DATE)
            THEN (DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 day')::date
            ELSE COALESCE({{end_date}}, CURRENT_DATE)::date
        END AS period_end
),
installs AS (
    SELECT COUNT(*) AS value
    FROM customers_v4 c, target_period t
    WHERE c.is_deleted = FALSE
      AND c.creation_date::date BETWEEN t.period_start AND t.period_end
),
Activations AS (
    SELECT COUNT(*) AS value
    FROM customers_v4 c, target_period t
    WHERE c.first_account_link_date IS NOT NULL
      AND c.is_deleted = FALSE
      AND c.creation_date::date BETWEEN t.period_start AND t.period_end
),
kyc_completed AS (
    SELECT COUNT(DISTINCT k.customer_id) AS value
    FROM kyc_results_v4 k
    JOIN customers_v4 c ON k.customer_id = c._id, target_period t
    WHERE c.is_deleted = FALSE
      AND c.creation_date::date BETWEEN t.period_start AND t.period_end
),
first_txn AS (
    SELECT COUNT(DISTINCT a.customer_id) AS value
    FROM activities_v4 a
    JOIN customers_v4 c ON a.customer_id = c._id, target_period t
    WHERE a.created_at::date >= c.creation_date::date
      AND c.is_deleted = FALSE
      AND c.creation_date::date BETWEEN t.period_start AND t.period_end
),
funnel AS (
    SELECT 'Installs' AS step, value, 100.0 AS pct_of_previous
    FROM installs
    UNION ALL
    SELECT 'Activations', value, ROUND((value::numeric / (SELECT value FROM installs)) * 100, 2)
    FROM Activations
    UNION ALL
    SELECT 'KYC Completions', value, ROUND((value::numeric / (SELECT value FROM Activations)) * 100, 2)
    FROM kyc_completed
    UNION ALL
    SELECT 'First Transaction', value, ROUND((value::numeric / (SELECT value FROM kyc_completed)) * 100, 2)
    FROM first_txn
)
SELECT *
FROM funnel;
