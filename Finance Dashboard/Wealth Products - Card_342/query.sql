-- Dashboard: Finance Dashboard
-- Dashboard ID: 59
-- Chart: Wealth Products - Card
-- Card ID: 342
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:11
================================================================================

select 	
p.description,
count(p.description),
 CASE
        WHEN SUM(wcf.amount) >= 1000000000 THEN TO_CHAR(ROUND(SUM(wcf.amount) / 1000000000.0, 1), 'FM999999990.0') || 'B'
        WHEN SUM(wcf.amount) >= 1000000    THEN TO_CHAR(ROUND(SUM(wcf.amount) / 1000000.0, 1), 'FM999999990.0') || 'M'
        WHEN SUM(wcf.amount) >= 1000       THEN TO_CHAR(ROUND(SUM(wcf.amount) / 1000.0, 1), 'FM999999990.0') || 'K'
        ELSE TO_CHAR(SUM(wcf.amount), 'FM999999990')
    END AS total_amount
 from wealth_cash_flow_logs_v4 wcf 
 join products_v4 p on p.params_portfolioid = wcf.wealth_product_id
where wcf.payment_method = 'Card' and 
wcf.type = 1
group by p.description
