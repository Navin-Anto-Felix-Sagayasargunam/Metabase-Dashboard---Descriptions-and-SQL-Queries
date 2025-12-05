-- Dashboard: Benchmarks for MoEngage
-- Dashboard ID: 68
-- Chart: Day-1 Retention Rate
-- Card ID: 593
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:25
================================================================================

WITH registered_users AS (
    -- Users who registered in the last 10 days
    SELECT
        _id AS customer_id,
        CAST(creation_date AS DATE) AS registration_date
    FROM customers_v4
    WHERE creation_date >= DATEADD(day, -10, CURRENT_DATE)
      AND creation_date <= CURRENT_DATE
),
active_next_day AS (
    -- Users who were active on Day 1
    SELECT
        r.customer_id,
        r.registration_date
    FROM registered_users r
    JOIN sessions_v4 s
      ON r.customer_id = s.customer_id
     AND CAST(s.created_at AS DATE) = DATEADD(day, 1, r.registration_date)
)
SELECT
   TO_CHAR(r.registration_date, 'Mon DD, YYYY') AS registration_date,
    COUNT(DISTINCT r.customer_id) AS registered_users,
        COUNT(DISTINCT a.customer_id) AS active_day1,
    ROUND(
        COUNT(DISTINCT a.customer_id)::NUMERIC / COUNT(DISTINCT r.customer_id) * 100,
        2
    ) AS day1_retention_pct
FROM registered_users r
LEFT JOIN active_next_day a
  ON r.customer_id = a.customer_id
GROUP BY r.registration_date
ORDER BY r.registration_date;
