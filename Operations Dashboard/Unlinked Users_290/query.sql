-- Dashboard: Operations Dashboard
-- Dashboard ID: 53
-- Chart: Unlinked Users
-- Card ID: 290
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:58
================================================================================

select count(*) as Unlinked_users from customers_v4
where first_account_link_date is null 
and is_deleted = 'False'