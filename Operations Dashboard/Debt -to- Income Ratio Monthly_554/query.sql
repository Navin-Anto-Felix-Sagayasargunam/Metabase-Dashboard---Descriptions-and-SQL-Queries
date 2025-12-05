-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Debt -to- Income Ratio Monthly
-- Card ID: 554
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:05
================================================================================

SELECT
    pay_period,
    TO_CHAR(TO_DATE(pay_period::text, 'YYYYMM'), 'Mon YYYY') AS pay_period_label,
    SUM(debt_affordability_ratio_monthly_debt_payment) AS total_debt_payment,
    SUM(debt_affordability_ratio_monthly_income) AS gross_income,
    ROUND(
        (SUM(debt_affordability_ratio_monthly_debt_payment)::numeric / NULLIF(SUM(debt_affordability_ratio_monthly_income), 0)) * 100,
        1
    ) AS dti_ratio_percentage
FROM financial_health_score_v4
WHERE pay_period::int BETWEEN 
      TO_CHAR(DATE_TRUNC('month', {{start_date}}::timestamp), 'YYYYMM')::int
  AND TO_CHAR(DATE_TRUNC('month', {{end_date}}::timestamp), 'YYYYMM')::int
GROUP BY pay_period
ORDER BY pay_period::int;
