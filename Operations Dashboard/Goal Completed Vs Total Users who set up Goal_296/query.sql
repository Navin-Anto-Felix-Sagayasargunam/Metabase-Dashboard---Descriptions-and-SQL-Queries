-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Goal Completed Vs Total Users who set up Goal
-- Card ID: 296
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:59
================================================================================

SELECT
    COUNT(DISTINCT CASE WHEN journey_step = 5 THEN customer_id END) AS completed_users,
    COUNT(*) AS total_goals,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN journey_step = 5 THEN customer_id END) 
        / NULLIF(COUNT(*), 0), 2
    ) AS completion_pct
FROM goals_v2_v4;
