-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Goal Progression ,by Journey Step
-- Card ID: 295
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:36
================================================================================

SELECT 
    CASE journey_step
        WHEN 1 THEN 'Step1 - Goal Creation '
        WHEN 2 THEN 'Step2 - Investment Style'
        WHEN 3 THEN 'Step3 - Goal Calculator'
        WHEN 4 THEN 'Step4 - Product Selection'
        WHEN 5 THEN 'Step5 - Completed'
        WHEN 6 THEN 'Step6 - Product Advice'
        ELSE 'Unknown'
    END AS journey_step_name,
    COUNT(*) AS step_count
FROM goals_v2_v4
GROUP BY journey_step_name
ORDER BY journey_step_name ASC;
