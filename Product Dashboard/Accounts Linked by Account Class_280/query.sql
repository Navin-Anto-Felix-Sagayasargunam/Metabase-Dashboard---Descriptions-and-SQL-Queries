-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Accounts Linked by Account Class
-- Card ID: 280
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:11
================================================================================

SELECT 
    COUNT(*) AS account_count,
    al.account_class
FROM accounts_v4 AS al
WHERE -- al.service_provider_id = '4dc7a3548aafd900a0000001'  -- uncomment if needed
      al.is_deleted = 'False'
  AND al.deactivated = 'False'
  AND al.refresh_status = 0
  [[AND al.account_class IN ({{account_class}})]]
GROUP BY al.account_class;
