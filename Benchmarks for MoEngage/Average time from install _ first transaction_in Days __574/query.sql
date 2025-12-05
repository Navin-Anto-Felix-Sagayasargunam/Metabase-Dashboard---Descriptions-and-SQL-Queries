-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Average time from install → first transaction(in Days )
-- Card ID: 574
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:20
================================================================================

WITH customer_first_txn AS (
    SELECT
        c._id AS customer_id,
        c.creation_date::timestamp AS install_date,
        MIN(a.transaction_date::timestamp) AS first_transaction_date,
        CASE 
            WHEN v._t = 'VaultUAEProfile' THEN 'UAE'
            ELSE 'SA'
        END AS profile_type
    FROM customers_v4 c
    JOIN accounts_v4 acc
        ON acc.customer_id = c._id
    JOIN activities_v4 a
        ON a.account_id = acc._id
    LEFT JOIN vault_profiles_v4 v
        ON c._id = v.customer_id
    WHERE a.transaction_date IS NOT NULL
      AND acc.account_class != 'Manual'
      AND a.transaction_date::date >= c.creation_date::date
      [[AND CASE WHEN v._t = 'VaultUAEProfile' THEN 'UAE' ELSE 'SA' END = {{profile_type}}]] -- optional filter
    GROUP BY c._id, c.creation_date, v._t
),
monthly_avg AS (
    SELECT
        DATE_TRUNC('month', install_date) AS month_start,
        profile_type,
        ROUND(
            SUM(EXTRACT(EPOCH FROM (first_transaction_date - install_date)) / 86400) 
            / NULLIF(COUNT(*),0), 2
        ) AS avg_days_install_to_txn,
        COUNT(*) AS users_included
    FROM customer_first_txn
    WHERE install_date::date >= COALESCE({{start_date}}, DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '12 month')
      AND install_date::date <= COALESCE({{end_date}}, CURRENT_DATE)
      AND DATE_TRUNC('month', install_date) < DATE_TRUNC('month', CURRENT_DATE)  -- completed months
    GROUP BY DATE_TRUNC('month', install_date), profile_type
)
SELECT
    month_start,
    TO_CHAR(month_start, 'Mon YYYY') AS month_label,
    profile_type,
    ROUND(avg_days_install_to_txn, 0) AS avg_days_install_to_txn,  -- rounded to nearest integer
    ROUND(
        LAG(avg_days_install_to_txn) OVER (PARTITION BY profile_type ORDER BY month_start), 0
    ) AS prev_month_avg,
    ROUND(
        ((avg_days_install_to_txn - LAG(avg_days_install_to_txn) OVER (PARTITION BY profile_type ORDER BY month_start))
         / NULLIF(LAG(avg_days_install_to_txn) OVER (PARTITION BY profile_type ORDER BY month_start), 0) * 100),
        2
    ) AS pct_change_vs_prev_month,
    users_included
FROM monthly_avg
ORDER BY month_start, profile_type;
