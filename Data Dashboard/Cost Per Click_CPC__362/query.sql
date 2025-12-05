-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Cost Per Click(CPC)
-- Card ID: 362
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:40
================================================================================

SELECT 
    SUM(advertiseradcost) / NULLIF(SUM(advertiseradclicks), 0) AS cost_per_click
FROM google_analytics_advertiserdetails
WHERE advertiseradcost > 0
  AND advertiseradclicks > 0
  AND date BETWEEN COALESCE({{start_date}}, CURRENT_DATE - interval '30 days') 
               AND COALESCE({{end_date}}, CURRENT_DATE);
