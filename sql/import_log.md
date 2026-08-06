# SQL Import Log — `freshroute` database

Continues the cleaning-phase **Data_Quality_Log** sheet in `data/cleaned/freshroute_cleaned Final.xlsx`. Covers the load of `data/cleaned/csv/*.csv` into PostgreSQL (via psql COPY) on 2026-07-16, per `create_tables.sql`.

## Entries

### 1. Column-order bug — products (2026-07-16)

- **Issue:** `create_tables.sql` defined `products` with `storage_type` before `brand`; the cleaned CSV (and data dictionary) order is `brand`, then `storage_type`. COPY maps columns by position and both columns are VARCHAR, so the import succeeded silently with every product's brand and storage type transposed.
- **Rows affected:** all rows of `products`.
- **Fix:** swapped the two columns in `CREATE TABLE products` to match the CSV. Because `products` is a parent of `batches`, `orders`, and `complaints`, the fix required dropping and rebuilding everything — which is also why the `DROP TABLE … CASCADE` block (children first) now sits at the top of `create_tables.sql`. Full import re-run afterwards.
- **Lesson:** verify data, not just load success — a positional bulk load can be silently wrong.

### 2. B-0041 exclusion and its ripple (2026-07-16)

- **Issue:** batch **B-0041** (product P-030, supplier S-08, batch number PS-2604-C) has `manufacture_date` 2026-12-01 *after* `expiry_date` 2026-04-30 — a genuine error in the raw file (flagged Open in the cleaning log; real dates unknown). It violates `chk_batch_dates`.
- **Fix:** excluded to `batches_exceptions` with reason "manufacture date after expiry date (violates chk_batch_dates)".
- **Ripple:** 5 child rows referenced B-0041 and would in turn have violated their batch foreign key:
  - 4 orders — O-00503, O-00575, O-01314, O-01369 (all P-030; combined sales value $369.28)
  - 1 complaint — CMP-028 (Short dated, High, In progress)

### 3. Option B decision — B-0041's dependent rows (2026-07-16)

- **Options considered:** (A) divert the 4 orders and 1 complaint to exceptions tables along with their batch; (B) keep them in `orders` / `complaints` with `batch_id` set to NULL.
- **Decision: Option B.** The sales and the complaint are genuine business events — only the batch link is unusable. Keeping them preserves sales totals and complaint history; they join the existing "no batch link" population that this project exists to measure (see task B6).
- **Rows affected:** 5 rows updated (`batch_id` → NULL); 0 rows excluded.

## Exceptions tables after import

| Table | Rows | Contents |
|---|---|---|
| `batches_exceptions` | 1 | B-0041 (dates violate `chk_batch_dates`) |
| `orders_exceptions` | 3 | O-00101, O-00201 (orphan customers C-999, C-888); O-00501 (dispatch before order date, source error accepted in cleaning log) |
| `recall_risk_exceptions` | 1 | RR-006 (references non-existent batch B-9999) |

## Post-import verification (2026-07-16)

- `YD-2408-A` (mock recall batch) → B-0187, quantity_received 480, **quantity_remaining 152** — matches the cleaned source. ✔
- `C-071` returns **zero rows** in `customers`, `orders`, and `complaints` (raw file had customer C-071 with 25 order references and 1 complaint reference; all re-pointed/removed during Excel cleaning — see Data_Quality_Log). ✔
- `B-0041`: 0 rows in `batches`, 1 row in `batches_exceptions`; its 4 orders and 1 complaint are present with `batch_id` NULL. ✔
