-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Click through Rate
-- Card ID: 364
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:40
================================================================================

SELECT 
    (SUM(advertiseradclicks)::decimal / NULLIF(SUM(advertiseradimpressions), 0)) * 100 AS click_through_rate
FROM google_analytics_advertiserdetails
WHERE advertiseradclicks > 0
  AND advertiseradimpressions > 0
  AND date BETWEEN COALESCE(CURRENT_DATE - interval '30 days') 
               AND COALESCE(CURRENT_DATE);
