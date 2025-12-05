-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Percentage of Users with atleast one financial Product
-- Card ID: 601
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:28
================================================================================

WITH financial_users AS (
    SELECT DISTINCT customer_id
    FROM (
        SELECT customer_id
        FROM accounts_v4
        WHERE available_balance_debit_or_credit = 'credit'
          AND is_deleted = 'False'
          AND include_in_nav = 'True'
          AND account_display_type IN ('Savings', 'Loan', 'Insurance')

        UNION ALL

        SELECT customer_id
        FROM wealth_account_investments_v4
        WHERE is_deleted = 'False'
    ) combined
),

all_users AS (
    SELECT DISTINCT _id 
    FROM customers_v4
    WHERE is_deleted = 'False'
	and first_account_link_date is not null 
)

SELECT
    COUNT(DISTINCT f.customer_id) AS users_with_financial_product,
    COUNT(DISTINCT a._id) AS total_users,
    ROUND(
        (COUNT(DISTINCT f.customer_id)::numeric / NULLIF(COUNT(DISTINCT a._id), 0)) * 100,
        2
    ) AS pct_users_with_financial_product
FROM all_users a
LEFT JOIN financial_users f
  ON a._id = f.customer_id;
