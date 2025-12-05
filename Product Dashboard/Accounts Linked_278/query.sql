-- Dashboard: Product Dashboard 
-- Dashboard ID: 58
-- Chart: Accounts Linked
-- Card ID: 278
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:22:10
================================================================================

SELECT count(*)
FROM accounts_v4 AS al
WHERE -- al.service_provider_id = '4dc7a3548aafd900a0000001'  -- uncomment if needed
      al.is_deleted = 'False'
  AND al.deactivated = FALSE
   and al.refresh_status = 0
and account_class != 'Manual';