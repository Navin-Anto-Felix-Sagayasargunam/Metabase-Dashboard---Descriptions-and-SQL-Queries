-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Total Ad Spent by Campaigns
-- Card ID: 361
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:39
================================================================================

SELECT 
    campaignname,
    SUM(advertiseradcost) AS total_ad_spend
FROM google_analytics_advertiserdetails
WHERE advertiseradcost > 0
  AND date BETWEEN COALESCE(CURRENT_DATE - interval '30 days') 
               AND COALESCE(CURRENT_DATE)
GROUP BY campaignname
HAVING SUM(advertiseradcost) > 0
ORDER BY total_ad_spend DESC;

