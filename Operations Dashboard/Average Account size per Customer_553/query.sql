-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Average Account size per Customer
-- Card ID: 553
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:05
================================================================================

WITH customer_totals AS (
    SELECT
        customer_id,
        SUM(available_balance_amount) AS total_balance_per_customer
    FROM accounts_v4
    WHERE is_deleted = 'False'
      AND include_in_nav = 'True'
      AND last_updated >= {{start_date}}::timestamp
      AND last_updated <= {{end_date}}::timestamp
    GROUP BY customer_id
)
SELECT
    COUNT(customer_id) AS total_customers,
    SUM(total_balance_per_customer) AS total_balance_all_customers,
    ROUND(
        SUM(total_balance_per_customer)::numeric / NULLIF(COUNT(customer_id), 0), 0
    ) AS average_account_size_per_customer,
    CASE
        WHEN ROUND(SUM(total_balance_per_customer)::numeric / NULLIF(COUNT(customer_id), 0), 0) >= 1000000000
            THEN ROUND(SUM(total_balance_per_customer)::numeric / NULLIF(COUNT(customer_id), 0) / 1000000000, 0)::text || 'B'
        WHEN ROUND(SUM(total_balance_per_customer)::numeric / NULLIF(COUNT(customer_id), 0), 0) >= 1000000
            THEN ROUND(SUM(total_balance_per_customer)::numeric / NULLIF(COUNT(customer_id), 0) / 1000000, 0)::text || 'M'
        WHEN ROUND(SUM(total_balance_per_customer)::numeric / NULLIF(COUNT(customer_id), 0), 0) >= 1000
            THEN ROUND(SUM(total_balance_per_customer)::numeric / NULLIF(COUNT(customer_id), 0) / 1000, 0)::text || 'K'
        ELSE ROUND(SUM(total_balance_per_customer)::numeric / NULLIF(COUNT(customer_id), 0), 0)::text
    END AS average_account_size_formatted
FROM customer_totals;
