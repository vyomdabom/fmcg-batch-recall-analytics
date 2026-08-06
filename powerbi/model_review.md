# Power BI Data Model Review — FreshRoute Foods

Reviewed against `ba-documents/erd.dbml`, `sql/create_tables.sql`, `sql/cleaning_queries.sql`, `sql/import_log.md`, `data/data_dictionary.md`, and `powerbi/dashboard_requirements.md`. Findings are grounded in those files plus the model-view screenshot, not assumptions.

## Verdict

The underlying schema is sound — normalised, correct keys, sensible cardinalities, and a well-documented decision to keep unlinked rows (nullable `batch_id`). Referential integrity is already proven: every orphan check in `cleaning_queries.sql` returns no rows, so the relationships will be clean once they're wired correctly. The problems are in the Power BI layer, not the data. One is a hard blocker (`customers`), one is a modelling decision you must make deliberately (a relationship loop), and the rest are setup gaps that will bite specific dashboard pages. Fix the P0 and P1 items before building visuals.

---

## P0 — Blocker: `customers` table is broken

The model shows `customers` with fields `Column1`–`Column6` instead of real names. The cleaned source is fine — `data/cleaned/csv/customers.csv` starts with a proper header row (`customer_id,customer_name,customer_type,region,contact_person,account_status`). So this is a **missing "Use First Row as Headers" step** in Power Query (or a step dropped after a source change). Consequences:

- There is no `customer_id` column, so the two relationships that depend on it — `orders[customer_id] → customers` and `complaints[customer_id] → customers` — cannot exist. In the diagram `customers` sits effectively isolated, which confirms this.
- The real header row is now the first *data* row, so even a manual join on `Column1` would carry a junk "customer_id" member and every name/type/region is offset by one.
- Everything customer-driven breaks: **Page 4** "customers who received this batch" (the recall contact list — the core purpose of the tool), **Page 5** complaints by customer type, **Page 1** total-customers KPI, and the customer-type / region slicers.

**Fix:** In Power Query, select the `customers` query → Home → *Use First Row as Headers*. Set `customer_id`, `region`, `customer_type`, etc. to Text. Delete any stale relationship on the table, then recreate `orders[customer_id] → customers[customer_id]` and `complaints[customer_id] → customers[customer_id]` as one-to-many, single cross-filter direction. Verify `customer_id` is Text on both sides (a key typed as number silently fails to relate).

---

## P1 — Design issues to resolve before building

### 1. Relationship loop: orders/complaints reach `products` two ways

Both `orders` and `complaints` link to `products` **directly** (`product_id`) *and* **through** `batches` (`… → batches[product_id] → products`). That's a triangle — `orders → products`, `orders → batches`, `batches → products` — and Power BI won't allow two active paths between the same two tables. It silently deactivates one edge, which is almost certainly why several relationships render dotted in your diagram. If the wrong edge is inactive, product-level numbers will be quietly wrong.

You must pick which edge is inactive **on purpose**:

- Keep `orders → batches` (and `complaints → batches`) **active** — this is what powers Page 4 recall traceability (batch slicer → who received it).
- Keep `batches → products` **active** — Page 2 (expiry/stock value *by product*) and every recall screen need a batch's product.
- That forces `orders → products` and `complaints → products` to be the **inactive** ones.

The catch: with the direct link inactive, product attribution flows `orders → batches → products`, so the **17.6% of orders and ~46% of complaints that have no `batch_id`** drop out of product-sliced measures. Recover them either with `USERELATIONSHIP(orders[product_id], products[product_id])` inside the affected measures, or with a resolved-product calculated column, e.g. `product_key = COALESCE(RELATED(batches[product_id]), orders[product_id])`, used for product analysis. Whichever you choose, document it — this single decision is the most consequential one in the model.

### 2. No Date dimension

The model has eight date columns (`order_date`, `dispatch_date`, `manufacture_date`, `expiry_date`, `complaint_date`, `date_identified`, `issue_date`, `last_audit_date`) but no dedicated, marked Date table. The dashboard needs trend visuals (Pages 1 and 5), 30/60/90 expiry windows and "expiring ≤30 days" (Pages 1–2), and a consistent date slicer across facts — none of which work reliably without one.

**Fix:** Add a `dim_date` (`CALENDAR`/`CALENDARAUTO` or Power Query), mark it as the model's Date table, and relate it to the facts. Because several dates are role-playing (order vs dispatch vs expiry), make one relationship active (suggest `order_date`) and reach the others with `USERELATIONSHIP` or a second date dimension. Expiry-window logic is cleanest as calculated columns/measures against this table (`DATEDIFF(TODAY(), batches[expiry_date], DAY)` bucketed).

### 3. Exceptions tables shouldn't participate in the model

`batches_exceptions`, `orders_exceptions`, and `recall_risk_exceptions` are quarantine tables (1, 3, and 1 rows) that by design have **no** relationships — `erd.dbml` and `import_log.md` are explicit about this. The diagram appears to show at least one stray relationship (a dotted line from `batches_exceptions` toward `suppliers`, and a connector near `orders_exceptions`). Any relationship on these tables is wrong and risks someone dragging their fields into a visual expecting them to filter.

**Fix:** Remove every relationship from all three exceptions tables. Hide them from Report view (keep them loadable for a small data-quality/audit visual if you want to show the quarantine count). Group them into a display folder so they're clearly separate from the star.

---

## P2 — Correctness and hygiene

**Single cross-filter direction throughout.** Keep every relationship one-to-many, single direction (dimension → fact). With `batches` acting as both a fact and a bridge to `orders`/`complaints`/`recall_risk`, bidirectional filters here invite ambiguity and slow queries. The flows the dashboard needs all work single-direction: a batch slicer filters `orders` and `complaints`; `suppliers → batches → complaints` and `suppliers → batches → orders` also resolve without bidirectional.

**Key data types.** The DDL uses inconsistent lengths for the same key (`batches.batch_id VARCHAR(10)` vs `orders.batch_id VARCHAR(30)`; `product_id` VARCHAR(10) vs 20; `customer_id` VARCHAR(10) vs 20). Harmless in Postgres, but in Power BI a relationship fails if the two sides aren't the same type — confirm every join key is **Text** on both ends, especially after the `customers` header fix.

**Supplier attribution is partial — surface it.** `complaints` has no `supplier_id`; supplier is reached via `complaints → batches → suppliers`. Since ~46% of complaints have no batch, "complaints by supplier" (Page 3) only covers the linked ~54%. That's a real limitation, not a bug — show it as an explicit caveat/known-coverage figure rather than letting it read as a complete count. Also: attribute supplier-to-product **only through `batches`** (which carries both `product_id` and `supplier_id`); never join `suppliers[main_category]` to `products[product_category]` — the dictionary warns `main_category` "doesn't always match products actually supplied," so a category join would be wrong and fan out.

**Blank-key members are the KPI, not noise.** Nullable `batch_id` rows land in a blank member on the `batches` side. That's by design (Option B in `import_log.md`) and is exactly what Pages 4–5 must quantify ("% without a batch ID"). Make sure those visuals count blanks explicitly instead of filtering them away.

---

## Recommended target model

Dimensions: `products`, `suppliers`, `customers`, `dim_date` (new). Facts: `orders`, `complaints`, `batches`, `recall_risk`, `supplier_documents` (`batches` doubles as a bridge). Exceptions tables: hidden, unrelated.

Relationships (all one-to-many, single direction):

| From (many) | To (one) | State | Notes |
|---|---|---|---|
| `batches[product_id]` | `products[product_id]` | Active | |
| `batches[supplier_id]` | `suppliers[supplier_id]` | Active | |
| `orders[customer_id]` | `customers[customer_id]` | Active | after P0 fix |
| `orders[batch_id]` | `batches[batch_id]` | Active | blank for 17.6% — by design |
| `complaints[customer_id]` | `customers[customer_id]` | Active | after P0 fix |
| `complaints[batch_id]` | `batches[batch_id]` | Active | blank for ~46% — by design |
| `supplier_documents[supplier_id]` | `suppliers[supplier_id]` | Active | |
| `recall_risk[batch_id]` | `batches[batch_id]` | Active | |
| `orders[product_id]` | `products[product_id]` | **Inactive** | breaks the loop; USERELATIONSHIP for no-batch rows |
| `complaints[product_id]` | `products[product_id]` | **Inactive** | same |
| `dim_date[date]` | `orders[order_date]` | Active | role-play others via USERELATIONSHIP |
| exceptions tables | — | none | quarantine only |

## Fix checklist, in order

1. Promote headers on `customers`; set key types to Text; recreate the two customer relationships. **(P0)**
2. Decide and set the active/inactive edges of the product loop; add `USERELATIONSHIP` measures (or a resolved-product column) so no-batch rows keep a product. **(P1)**
3. Add and mark a `dim_date`; wire trend and expiry-window logic to it. **(P1)**
4. Strip all relationships from the three exceptions tables; hide them from Report view. **(P1)**
5. Confirm every relationship is single-direction and every key is Text. **(P2)**
6. Smoke-test with mock batch **B-0187 / `YD-2408-A`** (received 480, remaining 152): the batch slicer should return its product, supplier, the customers who received it, and its linked complaints on Page 4.

## What's already good

The ERD is clean and correctly normalised; cardinalities are right. Keeping unlinked orders/complaints with `batch_id` NULL (rather than dropping them) is the correct, well-argued modelling choice and is the whole point of the analysis. The quarantine/exceptions pattern is proper ETL hygiene, and the `products` column-order transposition was already caught and fixed (`import_log.md` #1) — good verification discipline to carry into the model layer.
