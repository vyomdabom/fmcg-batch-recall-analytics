-- ============================================================
-- D14: RECALL TRACEABILITY — batch YD-2408-A
-- The query FreshRoute needed (6.5 hrs by hand → minutes here).
--
-- PLAN — what each answer needs and where it comes from:
--   1. batch + product + supplier details ...... batches → products, suppliers  (by product_id, supplier_id)
--   2. stock still in warehouse ................. batches.quantity_remaining (+ warehouse_location)
--   3. customers who received it ............... orders (batch_id = this batch) → customers
--        show: customer_name, region, quantity_sold, dispatch_date
--   4. regions affected ........................ DISTINCT delivery_region from those orders
--   5. recall exposure value ................... SUM(orders.sales_value)  +  (quantity_remaining × unit_cost)
--        (sold value already left the door + stock still on hand)
--   6. linked complaints ....................... complaints where batch_id = this batch
--
-- APPROACH: find the batch_id for batch_number 'YD-2408-A' first, then
--   several small result sets off it (customer list, region list, totals,
--   complaints) — do NOT cram into one giant join, it double-counts the sums.
--
-- CAVEAT to state in output: orders of this product with NULL batch_id in the
--   same period MIGHT contain this batch but can't be confirmed — the
--   traceability gap this whole project exposes.
-- ============================================================

-- TODO D14: for a parameterised batch_number return:
--   1) batch, product, supplier details

--   2) stock remaining + warehouse location -- 152 remaining at C2-A4 warehouse

--   3) all orders with customer, region, dispatch date, qty, value

--   4) distinct customers and regions affected
--   5) linked complaints
--   6) total recall exposure value (sold + remaining — compute separately!)

SELECT b.batch_id, p.product_name, s.supplier_name,p.product_id, p.unit_cost, b.quantity_remaining, b.warehouse_location, b.expiry_date
FROM batches b
LEFT JOIN products p On b.product_id = p.product_id
LEFT JOIN suppliers s ON b.supplier_id = s.supplier_id
WHERE b.batch_number = 'YD-2408-A';

SELECT o.order_id, b.batch_number, c.customer_id, c.customer_name, c.contact_person, o.batch_id, o.dispatch_date, o.quantity_sold, c.region
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN batches b ON b.batch_id = o.batch_id
Where b.batch_number = 'YD-2408-A';
--C-016 Addington Espresso Bar — has a NULL contact_person 
-- nationwide exposure

SELECT distinct c.region
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN batches b ON b.batch_id = o.batch_id
Where b.batch_number = 'YD-2408-A';

--exposure value
Select SUM(o.sales_value) AS sold_exposure
FROM orders o
JOIN batches b ON b.batch_id = o.batch_id
Where b.batch_number = 'YD-2408-A';
-- sold exposure

SELECT quantity_remaining, unit_cost, quantity_remaining * products.unit_cost as on_hand_value
FROM batches
join products ON batches.product_id = products.product_id
WHERE batch_number = 'YD-2408-A';
-- stock in warehouse 

-- total loss = 3205.55 + 503.12 = 3708.67

--   5) linked complaints
SELECT * FROM complaints WHERE batch_id = 'B-0187';

SELECT count(DISTINCT c.customer_id)
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN batches b ON b.batch_id = o.batch_id
Where b.batch_number = 'YD-2408-A';

--One-line purpose: "Full recall trace for batch YD-2408-A (B-0187), Yoghurt Drink 250ml, supplier Meadow Valley Dairy — the query set FreshRoute would run on receiving a recall notice."
--Who's affected: 18 customers across 22 orders (your Query 2 count), spanning Auckland, Bay of Plenty, Canterbury, Otago, Waikato, Wellington.
--Financial exposure: $3,708.67 total — $3,205.55 shipped, $503.12 on-hand. Broken out, as you have it.
--The early-warning nuance: CMP-099, an open Taste/Quality complaint on this batch from July 6, predates the recall notice.
--The gap that matters operationally: C-016 (Addington Espresso Bar) received the batch but has a NULL contact_person — a customer you can't phone.
--The caveat (the project's through-line): this trace only catches orders/complaints with batch_id filled in. With 17.6% of orders and 46% of complaints missing batch linkage, real exposure is a floor, not a ceiling — which is itself the strongest argument for fixing batch capture at point of sale.


-- TODO D15 (bonus): widened trace — all batches of same product+supplier in a date window