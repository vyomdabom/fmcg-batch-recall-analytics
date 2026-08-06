/* ============================================================
   analysis_queries.sql — business analysis
   Task ref: sql_tasks.md C7–C13
   ============================================================ */

-- TODO C7:  batches expiring within 30/60/90 days
WITH expiring AS (
   SELECT batch_id, product_id, quantity_remaining, warehouse_location,
          expiry_date, expiry_date - CURRENT_DATE AS days_to_expiry
   FROM batches
)
SELECT batch_id, product_id, quantity_remaining, warehouse_location, days_to_expiry,
   CASE
      WHEN days_to_expiry < 0 THEN 'Expired'
      WHEN days_to_expiry <= 30 THEN 'Critical'
      WHEN days_to_expiry <= 60 THEN 'High'
      WHEN days_to_expiry <= 90 THEN 'Medium'
      ELSE 'Low'
   END AS expiry_status
FROM expiring
WHERE days_to_expiry <= 90
  AND quantity_remaining > 0
ORDER BY days_to_expiry; -- 59 rows ordered from critical to low



-- TODO C8:  stock value at risk per window / product
WITH expiring as(
   SELECT batch_id, batches.product_id, quantity_remaining, warehouse_location, expiry_date, product_name,expiry_date - CURRENT_DATE AS days_to_expiry, unit_cost
   FROM batches
   JOIN products ON products.product_id = batches.product_id
),
classified as(
   Select batch_id, product_id, product_name, unit_cost, quantity_remaining, warehouse_location, days_to_expiry,
      CASE
         WHEN days_to_expiry < 0 THEN 'Expired'
         WHEN days_to_expiry <= 30 THEN 'Critical'
         WHEN days_to_expiry <= 60 THEN 'High'
         WHEN days_to_expiry <= 90 THEN 'Medium'
         ELSE 'LOW'
      END AS expiry_status
   FROM expiring
   WHERE days_to_expiry <= 90
   AND quantity_remaining > 0
   AND batch_id != 'B-0026' -- excluded: B-0026 corrupted quantity_received=48,000 (B5 finding)
)
Select expiry_status, count(*) AS batch_count, round(sum(quantity_remaining * unit_cost), 2) AS Value_at_risk
FROM classified
GROUP BY expiry_status;

-- TODO C9:  batches with missing or expired supplier documents
With CTE_clipboard AS (
   Select suppliers.supplier_id, doc_types.document_type
   FROM suppliers
   CROSS JOIN(
      SELECT DISTINCT document_type FROM supplier_documents
   ) AS doc_types
)
SELECT CTE_clipboard.supplier_id,CTE_clipboard.document_type, batches.batch_id
from CTE_clipboard
Left JOIN supplier_documents ON supplier_documents.supplier_id = CTE_clipboard.supplier_id AND supplier_documents.document_type = CTE_clipboard.document_type
JOIN batches on batches.supplier_id = CTE_clipboard.supplier_id
where supplier_documents.document_id is NULL
ORDER BY supplier_id, batch_id;

-- C9 missing-docs: 190 rows (batch × missing doc type); 156 distinct batches (52% of 298)
-- sourced from suppliers with ≥1 missing document type. 8 supplier/doc-type gaps total.
-- Caveat: assumes all 5 doc types required per supplier — confirm with Quality.


-- TODO C10: complaint rate per 1,000 units sold, by product

WITH CTE_sales AS(
   SELECT product_id, SUM(quantity_sold) as units_sold
   FROM orders
   GROUP BY product_id
),
complaint_counts AS(
   Select product_id, count(complaint_id) as complaint_count
   FROM complaints
   WHERE product_id is not null
   GROUP BY product_id
)
Select 
   CTE_sales.product_id, product_name, CTE_sales.units_sold, 
   coalesce(complaint_counts.complaint_count, 0) as complaint_count,
   round(coalesce(complaint_counts.complaint_count, 0) * 1000.0 / CTE_sales.units_sold, 2) as complaints_per_1000
From CTE_sales
LEFT join complaint_counts ON complaint_counts.product_id = CTE_sales.product_id
LEFT JOIN products on products.product_id = CTE_sales.product_id
ORDER BY complaints_per_1000 DESC;

-- C10 (run 2026-07-22): top complaint rates per 1,000 units 
-- Nut Bar Almond 45g 4.98, Almond Butter 250g 4.50, Kombucha Starter Kit 4.44.
-- LEFT JOIN keeps zero-complaint products (e.g. Cheese Slices 0.00).
-- Excludes 5 complaints with no product_id (unattributable).


-- TODO C11: supplier issue count (QC fails + complaints + recall risks)
WITH CTE_supplier_issue AS (
   SELECT supplier_id, 'Failed QC' as issue_type
   From batches
   WHERE quality_status = 'Failed'
   UNION ALL
   SELECT batches.supplier_id, 'Complaint' as issue_type
   FROM complaints
   JOIN batches on batches.batch_id = complaints.batch_id
   UNION ALL
   SELECT batches.supplier_id, 'Recall Risk' as issue_type
   FROM recall_risk
   JOIN batches on batches.batch_id = recall_risk.batch_id
   Where recall_risk.status IN ('Open', 'In progress')
)
Select 
   CTE_supplier_issue.supplier_id, suppliers.supplier_name, COUNT(*) AS total_issues,
   COUNT(*) FILTER (WHERE issue_type = 'Failed QC')  AS qc_fails,
   COUNT(*) FILTER (WHERE issue_type = 'Complaint')  AS complaints,
   COUNT(*) FILTER (WHERE issue_type = 'Recall Risk') AS recall_risks
FROM CTE_supplier_issue
JOIN suppliers ON suppliers.supplier_id = CTE_supplier_issue.supplier_id
GROUP BY CTE_supplier_issue.supplier_id, suppliers.supplier_name
ORDER BY Total_issues DESC;
-- Ranks all 14 suppliers by total quality issues (failed QC + batch-linked
-- complaints + open recall risks), broken down by source.
--
-- Top 3 by volume:
--   S-10 Kereru Organics       10  (2 QC, 7 complaints, 1 recall)
--   S-09 Bay Packaging Foods    8  (1 QC, 5 complaints, 2 recall)
--   S-07 Harvest Sauce Company  8  (1 QC, 5 complaints, 2 recall)
--
-- Note on Meadow Valley (S-01): 4th at 7 issues, but profile is distinctive —
-- 0 QC fails, 6 complaints, 1 OPEN recall risk. Not the highest-volume supplier,
-- but the live recall risk is why the YD-2408-A notification warrants urgency.
--
-- CAVEATS (this is a FLOOR, not a ceiling):
--   * 46 complaints have no batch_id, so cannot be attributed to a supplier —
--     complaint-driven issues are undercounted.
--   * 'In progress' recall risks counted as open (alongside 'Open').
--   * Orphan recall risk RR-006 (batch B-9999) dropped — no supplier to attribute.

-- TODO C12: top 10 high-risk batches (document your scoring weights here)
-- C12 scoring weights:
--   open recall risk = 5 (why: someone already judged this batch dangerous. Potentally hazardous for customer)
--   expired          = 4 (why: still on habd so can immediatly pull off shelf. Costly)
--   document problem = 2 (why: Compliance exposure)
--   has complaint    = 1 (why: Quality signal)

WITH CTE_complaintbatches AS (
   SELECT DISTINCT batch_id
   FROM complaints
   where batch_id is not NULL
),
CTE_recallbatches as(
   Select distinct batch_id
   From recall_risk
   Where status in ('Open', 'In progress')
)
SELECT 
   b.batch_id, b.product_id, b.quantity_remaining, expiry_date - CURRENT_DATE as days_to_expiry,
   (CASE WHEN rb.batch_id is not null then 5 else 0 end) +
   (CASE WHEN b.expiry_date < CURRENT_DATE THEN 4 ELSE 0 END) + 
   (CASE WHEN b.document_status in ('Incomplete', 'Missing') THEN 2 ELSE 0 END) +
   (CASE WHEN cb.batch_id is not null THEN 1 ELSE 0 END)
   AS risk_score
FROM batches b 
LEFT JOIN CTE_complaintbatches cb on b.batch_id = cb.batch_id
LEFT JOIN CTE_recallbatches rb on b.batch_id = rb.batch_id
WHERE b.quantity_remaining > 0
ORDER BY risk_score DESC
LIMIT 10;

-- C12 top-10 by risk score (recall 5, expired 4, doc 2, complaint 1).
-- Top: B-0076 (9), B-0293 (7). 
-- NOTE: the recall-scenario batch B-0187 scores only 3 and is NOT in the top 10,
-- because its supplier's recall notification is external and not yet in recall_risk.
-- This shows the internal risk model would miss an incoming recall — argues for a
-- process to log supplier notifications promptly.

-- TODO C13: avg resolution days by severity / category
SELECT severity, complaint_type, ROUND(AVG(resolution_days), 1) as avg_resolution_days, Count(*) as complaint_type
FROM complaints
where resolution_days >= 0
GROUP BY severity, complaint_type
order BY avg_resolution_days DESC;
-- C13 avg resolution days by severity + complaint type (run 2026-07-22).
-- Excludes CMP-021 (resolution_days = -3, impossible — B5 finding); NULLs
-- (open/unresolved complaints) ignored automatically by AVG.
-- Read with the count column: highest averages (Critical/Taste 18.0) are n=1
-- anecdotes. The meaningful slow group is HIGH-severity Taste/Quality:
-- ~11 days across 8 complaints — the real target for faster resolution.