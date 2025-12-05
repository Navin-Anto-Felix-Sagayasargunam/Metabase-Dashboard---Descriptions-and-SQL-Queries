-- Dashboard: Finance Dashboard
-- Dashboard ID: 59
-- Chart: KYC Completion Count
-- Card ID: 273
-- Query Type: native
-- Database ID: 2
-- Extracted: 2025-12-05 18:21:13
================================================================================

SELECT COUNT(*) AS string
FROM (
    SELECT customer_id, COUNT(*) AS total
	from kyc_results_v4
	WHERE lower(am_l_result_is_eligible) = 'true'
    GROUP BY customer_id
) AS KYC_Completion_Count ;