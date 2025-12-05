-- Dashboard: Finance Dashboard
-- Dashboard ID: 59
-- Chart: Wealth Products -EFT
-- Card ID: 339
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:12
================================================================================

SELECT 	
    p.description,	
    COUNT(p.description) AS txn_count,
  --  SUM(wcf.amount) AS total_amount,
    CASE
        WHEN SUM(wcf.amount) >= 1000000000 THEN TO_CHAR(ROUND(SUM(wcf.amount) / 1000000000.0, 1), 'FM999999990.0') || 'B'
        WHEN SUM(wcf.amount) >= 1000000    THEN TO_CHAR(ROUND(SUM(wcf.amount) / 1000000.0, 1), 'FM999999990.0') || 'M'
        WHEN SUM(wcf.amount) >= 1000       THEN TO_CHAR(ROUND(SUM(wcf.amount) / 1000.0, 1), 'FM999999990.0') || 'K'
        ELSE TO_CHAR(SUM(wcf.amount), 'FM999999990')
    END AS total_amount
FROM wealth_cash_flow_logs_v4 wcf
JOIN products_v4 p 
    ON p.params_portfolioid = wcf.wealth_product_id
WHERE wcf.payment_method = 'EFT' 
  AND wcf.type = 1
GROUP BY p.description;
