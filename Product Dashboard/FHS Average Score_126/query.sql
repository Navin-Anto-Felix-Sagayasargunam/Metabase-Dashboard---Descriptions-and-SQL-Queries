-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: FHS Average Score
-- Card ID: 126
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:14
================================================================================

WITH ffs_calculated AS (
    SELECT 
        u.customer_id,
        DATE_TRUNC('month', u.last_updated)::date AS month_yy,
        ROUND((
            (spend_ratio_score                 * 0.30) +
            (missed_payments_score             * 0.05) +
            (liquidity_ratio_score             * 0.20) +
            (retirement_readiness_ratio_score  * 0.10) +
            (debt_affordability_ratio_score    * 0.10) +
            (credit_card_balance_carry_over_score * 0.10) +
            (insurance_payments_score          * 0.05) +
            (average_monthly_logins_score      * 0.05)
        )::numeric, 2) AS ffs_score
    FROM financial_health_score_v4 u
    WHERE u.last_updated >= COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months')
      AND u.last_updated <= COALESCE({{end_date}}, CURRENT_DATE)
),
ffs_with_levels AS (
    SELECT 
        f.customer_id,
        f.month_yy,
        f.ffs_score,
        CASE 
            WHEN f.ffs_score > 0 and f.ffs_score <= 20 THEN 'Financial Fitness – Rookie'
            WHEN f.ffs_score > 20 and f.ffs_score <= 40 THEN 'Financial Fitness – Enthusiast'
            WHEN f.ffs_score > 40 and f.ffs_score <= 60 THEN 'Financial Fitness – Competitor'
            WHEN f.ffs_score > 60 and f.ffs_score <= 80 THEN 'Financial Fitness – Expert'
			WHEN f.ffs_score > 80 and f.ffs_score <= 100 THEN 'Financial Fitness – Elite'
           -- ELSE 'Financial Fitness – Elite'
        END AS ffs_level
    FROM ffs_calculated f
)
SELECT 
    TO_CHAR(month_yy, 'Mon yyyy') AS month_label,  -- 👈 Mon yyyy format
    ffs_level,
    ROUND(AVG(ffs_score), 8) AS avg_ffs_score,
    COUNT(DISTINCT customer_id) AS users_count
FROM ffs_with_levels
GROUP BY month_yy, ffs_level
ORDER BY month_yy, ffs_level;
