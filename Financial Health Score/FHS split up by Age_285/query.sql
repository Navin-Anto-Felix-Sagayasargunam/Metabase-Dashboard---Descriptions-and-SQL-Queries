-- Dashboard: Financial Health Score 
-- Dashboard ID: 26
-- Chart: FHS split up by Age
-- Card ID: 285
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:16
================================================================================

WITH ffs_calculated AS (
    SELECT
        c._id AS customer_id,
        FLOOR(DATEDIFF(day, c.date_of_birth, fhs.last_updated) / 365.25) AS age,
        DATE_TRUNC('month', fhs.last_updated)::date AS month_yy,
        ROUND((
            (fhs.spend_ratio_score                 * 0.30) +
            (fhs.missed_payments_score             * 0.05) +
            (fhs.liquidity_ratio_score             * 0.20) +
            (fhs.retirement_readiness_ratio_score  * 0.10) +
            (fhs.debt_affordability_ratio_score    * 0.10) +
            (fhs.credit_card_balance_carry_over_score * 0.10) +
            (fhs.insurance_payments_score          * 0.05) +
            (fhs.average_monthly_logins_score      * 0.05)
        )::numeric, 2) AS ffs_score
    FROM customers_v4 c
    JOIN financial_health_score_v4 fhs
      ON c._id = fhs.customer_id
    WHERE DATE(fhs.last_updated) BETWEEN COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 months')
                                     AND COALESCE({{end_date}}, CURRENT_DATE)
),
ffs_with_age_group AS (
    SELECT 
        f.customer_id,
        f.month_yy,
        f.age,
        f.ffs_score,
        TO_CHAR(f.month_yy, 'Mon yyyy') AS month_label,
        CASE 
            WHEN f.ffs_score < 20 THEN 'Financial Fitness – Rookie'
            WHEN f.ffs_score < 40 THEN 'Financial Fitness – Enthusiast'
            WHEN f.ffs_score < 60 THEN 'Financial Fitness – Competitor'
            WHEN f.ffs_score < 80 THEN 'Financial Fitness – Expert'
            ELSE  'Financial Fitness – Elite'
        END AS ffs_level,
        CASE 
            WHEN f.age < 20 THEN '<20'
            WHEN f.age BETWEEN 21 AND 30 THEN '21-30'
            WHEN f.age BETWEEN 31 AND 40 THEN '31-40'
            WHEN f.age BETWEEN 41 AND 50 THEN '41-50'
            WHEN f.age BETWEEN 51 AND 60 THEN '51-60'
            WHEN f.age BETWEEN 61 AND 65 THEN '61-65'
            ELSE '65+'
        END AS age_group
    FROM ffs_calculated f 
)
SELECT 
    month_yy,
    month_label,
    ffs_level,
    age_group,
    ROUND(AVG(ffs_score), 2) AS avg_ffs_score,
    COUNT(DISTINCT customer_id) AS users_count
FROM ffs_with_age_group
GROUP BY month_yy, month_label, ffs_level, age_group
ORDER BY month_yy, ffs_level, age_group;
