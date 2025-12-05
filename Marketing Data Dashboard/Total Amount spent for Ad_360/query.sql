-- Dashboard: Marketing Data Dashboard 
-- Dashboard ID: 50
-- Chart: Total Amount spent for Ad
-- Card ID: 360
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:39
================================================================================

SELECT 
    SUM(advertiseradcost) AS total_ad_spend
FROM google_analytics_advertiserdetails
WHERE date BETWEEN COALESCE(CURRENT_DATE - interval '30 days') 
               AND COALESCE( CURRENT_DATE);
