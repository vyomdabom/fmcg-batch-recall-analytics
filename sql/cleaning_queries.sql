/* ============================================================
   cleaning_queries.sql — data quality verification
   Task ref: sql_tasks.md B3–B6
   ============================================================ */

-- B3: row counts per table vs raw
SELECT 'products' AS table_name, COUNT(*) AS row_count FROM products
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'complaints', COUNT(*) FROM complaints
UNION ALL
SELECT 'supplier documents', COUNT(*) FROM supplier_documents
UNION ALL
SELECT 'recall risk', COUNT(*) FROM recall_risk
UNION ALL
SELECT 'batches exceptions', COUNT(*) FROM batches_exceptions
UNION ALL
SELECT 'orders exceptions', COUNT(*) FROM orders_exceptions
UNION ALL
SELECT 'recall risk exceptions', COUNT(*) FROM recall_risk_exceptions;

-- B4: orphan checks (orders → batches/customers, complaints → FKs)
SELECT orders.order_id -- No Data (good)
from orders
Left JOIN batches ON orders.batch_id = batches.batch_id
where batches.batch_id is NULL
AND orders.batch_id IS NOT NULL;

SELECT orders.customer_id -- No Data (good)
from orders
LEFT JOIN customers ON orders.customer_id = customers.customer_id
where customers.customer_id is NULL;


SELECT orders.product_id -- No Data (good)
from orders
LEFT JOIN products ON orders.product_id = products.product_id
where products.product_id is NULL
AND orders.product_id is not NULL;

SELECT batches.supplier_id -- No Data (good)
from batches
LEFT JOIN suppliers ON batches.supplier_id = suppliers.supplier_id
where suppliers.supplier_id is NULL;

SELECT batches.product_id -- No Data (good)
from batches
LEFT JOIN products ON batches.product_id = products.product_id
where products.product_id is NULL;

SELECT complaints.product_id -- No Data (good)
from complaints
LEFT JOIN products ON complaints.product_id = products.product_id
where products.product_id is NULL
AND complaints.product_id is not NULL;

SELECT complaints.customer_id -- No Data (good)
from complaints
Left JOIN customers ON complaints.customer_id = customers.customer_id
where customers.customer_id is NULL
AND complaints.customer_id is not NULL;

SELECT complaints.batch_id -- No Data (good)
from complaints
LEFT JOIN batches ON complaints.batch_id = batches.batch_id
where batches.batch_id is NULL
AND complaints.batch_id is not NULL ;

SELECT supplier_documents.supplier_id -- No Data (good)
from supplier_documents
LEFT JOIN suppliers ON supplier_documents.supplier_id = suppliers.supplier_id
where suppliers.supplier_id is NULL;

SELECT recall_risk.batch_id -- No Data (good)
from recall_risk
LEFT JOIN batches ON recall_risk.batch_id = batches.batch_id
where batches.batch_id is NULL;

SELECT orders_exceptions.order_id, orders_exceptions.customer_id -- control
FROM orders_exceptions
LEFT JOIN customers ON orders_exceptions.customer_id = customers.customer_id
WHERE customers.customer_id IS NULL;

--316 of 1,796 orders (17.6%) have no batch linkage 
-- 5 nulls in complaints from products in product_id
-- 46 null in the complaints table for batch_id
-- positive control returned the 2 known orphan orders (O-00101, O-00201) — detector verified

-- B5: impossible values (negative qty, remaining > received, dispatch_date < order_date, manufacture_date > expiry_date)

SELECT * FROM batches where quantity_received < quantity_remaining; -- 5 rows show that there are more batches remaining than quantity recieved
SELECT * FROM batches where quantity_received < 0 ; -- Batch B-0011 has a negitive quantity recieved (-120).
SELECT * FROM batches ORDER BY quantity_received DESC LIMIT 5; ---- B-0026: quantity_received 48,000 vs plausible max ~960 — probable data entry error, flagged for exclusion decision in C8
SELECT * FROM orders where quantity_sold <= 0; -- O-00301 has sold quantity sold as 0 and O-00401 has a negitive value (-24) for quantity sold.
SELECT * FROM complaints WHERE resolution_days <= 0; -- CMP-021 has resolution days for -3
SELECT * FROM orders Where dispatch_date < order_date; -- No data
SELECT * From batches Where manufacture_date > expiry_date; -- No data
SELECT * FROM batches where manufacture_date > DATE '2026-07-31';
-- FINDING (run 2026-07-17): 7 batches have manufacture_date in the future —
-- B-0009, B-0014, B-0169, B-0191, B-0214, B-0272, B-0275.
-- Spread across 5 different suppliers, so this points to missing date
-- validation at FreshRoute's goods-in process rather than one supplier's
-- paperwork. Values confirmed present in raw source (not import damage).
-- Action: flagged as data-quality finding; feeds recommendation on
-- input validation at receiving.
Select * FROM batches Where expiry_date <= DATE '2026-07-31' AND quantity_remaining > 0;

-- B6: data-quality summary (% orders / complaints missing batch_id)

SELECT 'orders.batch_id' AS column_checked,
       COUNT(*) - COUNT(batch_id) AS missing,
       COUNT(*) AS total,
       ROUND((COUNT(*) - COUNT(batch_id)) * 100.0 / COUNT(*), 1) AS pct_missing
FROM orders
UNION ALL
SELECT 'complaints.batch_id' AS column_checked,
       COUNT(*) - COUNT(batch_id) AS missing,
       COUNT(*) AS total,
       ROUND((COUNT(*) - COUNT(batch_id)) * 100.0 / COUNT(*), 1) AS pct_missing
FROM complaints
UNION ALL
SELECT 'complaints.product_id' AS column_checked,
       COUNT(*) - COUNT(product_id) AS missing,
       COUNT(*) AS total,
       ROUND((COUNT(*) - COUNT(product_id)) * 100.0 / COUNT(*), 1) AS pct_missing
FROM complaints