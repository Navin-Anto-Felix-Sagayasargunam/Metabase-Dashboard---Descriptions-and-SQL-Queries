-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Click Through Rate by Campaign
-- Card ID: 365
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:40
================================================================================

SELECT 
    campaignname,
    SUM(advertiseradimpressions) AS total_impressions,
    SUM(advertiseradclicks) AS total_clicks,
    (SUM(advertiseradclicks)::decimal / NULLIF(SUM(advertiseradimpressions), 0)) * 100 AS click_through_rate
FROM google_analytics_advertiserdetails
WHERE advertiseradclicks > 0
  AND advertiseradimpressions > 0
  AND date BETWEEN COALESCE(CURRENT_DATE - interval '30 days') 
               AND COALESCE(CURRENT_DATE)
GROUP BY campaignname
ORDER BY click_through_rate DESC;
