-- Dashboard: Data Dashboard
-- Dashboard ID: 56
-- Chart: Cost per Click by Campaigns
-- Card ID: 363
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:20:40
================================================================================

SELECT 
    campaignname,
    SUM(advertiseradcost) AS total_ad_spend,
    SUM(advertiseradclicks) AS total_clicks,
    SUM(advertiseradcost) / NULLIF(SUM(advertiseradclicks), 0) AS cost_per_click
FROM google_analytics_advertiserdetails
WHERE advertiseradcost > 0
  AND advertiseradclicks > 0
  AND date BETWEEN COALESCE(CURRENT_DATE - interval '30 days') 
               AND COALESCE(CURRENT_DATE)
GROUP BY campaignname
ORDER BY cost_per_click;
