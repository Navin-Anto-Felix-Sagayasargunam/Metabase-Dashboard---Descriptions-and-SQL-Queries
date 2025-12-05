-- Dashboard: Sales Dashboard
-- Dashboard ID: 55
-- Chart: Rate of Goal Completion
-- Card ID: 297
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:32
================================================================================

SELECT
    COUNT(DISTINCT CASE WHEN journey_step = 5 THEN customer_id END) AS completed_users,
    COUNT(*) AS total_goals,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN journey_step = 5 THEN customer_id END) 
        / NULLIF(COUNT(*), 0), 2
    ) AS completion_pct
FROM goals_v2_v4;
