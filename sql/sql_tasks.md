# SQL Tasks

> Write the queries yourself in the four .sql files (skeletons provided). Hints only — no solutions. Pick one dialect and state it in the README.

## A. Setup — `create_tables.sql`

1. Create the 8 tables with appropriate types, primary keys, and foreign keys.
   *Hint: decide NULL vs NOT NULL per column using the data dictionary — batch_id on orders must allow NULL (that's the business problem). Add CHECK constraints where impossible values occurred (quantities ≥ 0).*
2. Import cleaned data (BULK INSERT / COPY / import wizard — document which).

## B. Cleaning verification — `cleaning_queries.sql`

3. Count rows per table; compare to raw.
4. Find remaining orphans: orders with batch_id/customer_id not in parent tables; complaints with invalid FKs.
   *Hint: LEFT JOIN … WHERE parent.pk IS NULL.*
5. Find surviving impossible values (negative qty, remaining > received, dispatch < order date, manufacture > expiry).
6. Produce the data-quality summary: % orders missing batch_id, % complaints missing batch_id.
   *Hint: AVG(CASE WHEN … THEN 1.0 ELSE 0 END) or COUNT filtered / COUNT(*).*

## C. Analysis — `analysis_queries.sql`

7. Batches expiring within 30 / 60 / 90 days with quantity remaining and location.
   *Hint: date difference from CURRENT_DATE; a CASE expression makes the window label reusable. Exclude quantity_remaining = 0? Your call — justify it.*
8. Stock value at risk per expiry window and per product.
   *Hint: quantity_remaining × unit_cost; join Batches → Products.*
9. Batches whose supplier has missing or expired documents.
   *Hint: two problems — expired rows (WHERE expiry_date < today) and absent rows (which suppliers have NO row of a required document type — think LEFT JOIN against a required-docs list or NOT EXISTS).*
10. Complaint rate by product: complaints per 1,000 units sold.
    *Hint: aggregate complaints and orders separately (CTEs) before joining — joining then grouping double-counts.*
11. Supplier issue count: failed QC batches + linked complaints + open recall risks per supplier.
    *Hint: UNION ALL the three issue sources with a source label, then group.*
12. Rank the top 10 high-risk batches.
    *Hint: build a simple score (near expiry + doc issues + complaints + recall flags), then RANK()/ROW_NUMBER(). Defining the score is a design decision — document your weights.*
13. Average complaint resolution days by severity and by product category.

## D. Recall traceability — `recall_traceability_query.sql`

14. **The showcase query.** For a given batch_number (parameterise it; test with `YD-2408-A`):
    - product and supplier details
    - quantity remaining in warehouse + location
    - all orders: customer, region, dispatch date, quantity, sales value
    - distinct customers affected and regions affected
    - linked complaints
    - total recall exposure value
    *Hint: one master CTE finding the batch_id(s) for the batch number, then several small result sets off it. A single giant join will double-count — exposure needs sold value and remaining value computed separately.*
15. Bonus: same trace but for "all batches of this product from this supplier in a date window" — real recalls often widen.

## Verification habit

For every analysis query, sanity-check one result manually against the spreadsheet before trusting it. Note one example check in your final report.
