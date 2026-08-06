# Data Dictionary & Dataset Design

> Structure only — **you generate the data** (manually, with Excel formulas, or a Python/Excel random generator you write). Save raw messy files in `data/raw/` (one workbook with 8 sheets, or 8 files) and cleaned versions in `data/cleaned/`.
>
> **Suggested volumes:** Products 45–60 · Suppliers 12–15 · Batches 250–350 · Customers 60–80 · Orders 1,500–2,500 · Complaints 80–120 · Supplier Documents 45–60 · Recall Risk 25–40. Date range: ~18 months ending "today". Make sure batch `YD-2408-A` (the mock recall batch) exists with realistic sold + remaining stock.

## 1. Products

| Field | Type | Description | Example | Messy-data notes |
|---|---|---|---|---|
| product_id | Text (PK) | Unique ID, format P-xxx | P-014 | A few duplicated IDs with slightly different names |
| product_name | Text | Product + size | Yoghurt Drink 250ml | Spelling variants ("Yogurt Drink 250 ml") |
| product_category | Text | Dairy, Chilled Drinks, Protein Bars, Frozen Meals, Snacks, Sauces, Packaged, Health | Dairy | Inconsistent casing; "Snack" vs "Snacks" |
| brand | Text | Brand name | KiwiFresh | Blanks on a few rows |
| storage_type | Text | Chilled / Frozen / Ambient | Chilled | "chilled", "CHILLED", one "Fridge" |
| unit_cost | Decimal | Cost per unit NZD | 1.85 | One or two entered as text with "$" |
| unit_sell_price | Decimal | Sell price per unit NZD | 3.10 | One row where sell < cost (query it later!) |
| active_status | Text | Active / Discontinued | Active | Blank for some; orders exist against Discontinued products |

## 2. Suppliers

| Field | Type | Description | Example | Messy-data notes |
|---|---|---|---|---|
| supplier_id | Text (PK) | S-xx | S-04 | — |
| supplier_name | Text | Legal name | Meadow Valley Dairy Ltd | Variants: "MeadowValley Dairy", "Meadow Valley dairy ltd" |
| country | Text | Country of origin | New Zealand | "NZ", "N.Z.", "Australia"/"AUS" mixed |
| supplier_rating | Integer | 1–5 internal rating | 4 | Some blank; one 0; one 6 |
| main_category | Text | Main category supplied | Dairy | Doesn't always match products actually supplied |
| last_audit_date | Date | Last quality audit | 2025-03-14 | Mixed formats: 14/03/2025, 14-Mar-25; some >2 years old; some blank |
| certification_status | Text | Certified / Pending / Expired | Certified | Contradicts Supplier Documents sheet for 1–2 suppliers (deliberate!) |

## 3. Batches

| Field | Type | Description | Example | Messy-data notes |
|---|---|---|---|---|
| batch_id | Text (PK) | Internal ID B-xxxx | B-0187 | — |
| product_id | Text (FK) | Links to Products | P-014 | A couple reference a duplicate/discontinued product |
| supplier_id | Text (FK) | Links to Suppliers | S-04 | — |
| batch_number | Text | Supplier batch code | YD-2408-A | ~5% blank; inconsistent formats between suppliers |
| manufacture_date | Date | Production date | 2026-05-02 | Mixed formats; one AFTER expiry date |
| expiry_date | Date | Use-by/best-before | 2026-08-02 | ~3% blank; mixed formats; some stored as text |
| quantity_received | Integer | Units received | 480 | One negative value; one absurd (48000) |
| quantity_remaining | Integer | Units in warehouse now | 130 | A few rows where remaining > received |
| warehouse_location | Text | Zone-aisle, e.g. C2-A4 | C2-A4 | Chilled product in an ambient zone code on 1–2 rows |
| quality_status | Text | Passed / Failed / Pending / Hold | Passed | Blank on some rows |
| document_status | Text | Complete / Incomplete / Missing | Complete | Should be derivable from Supplier Documents — inconsistencies exist |

## 4. Customers

| Field | Type | Description | Example | Messy-data notes |
|---|---|---|---|---|
| customer_id | Text (PK) | C-xxx | C-032 | — |
| customer_name | Text | Trading name | Ponsonby Corner Dairy | One customer entered twice with name variants |
| customer_type | Text | Supermarket / Dairy / Cafe / Restaurant / Small Retailer | Cafe | "Café" vs "Cafe" |
| region | Text | NZ region | Auckland | "Akl", "AKL", "Auckland "; "Wgtn"/"Wellington" |
| contact_person | Text | Main contact | Sarah Ng | Blanks |
| account_status | Text | Active / On hold / Closed | Active | Orders exist for a Closed account |

## 5. Orders

| Field | Type | Description | Example | Messy-data notes |
|---|---|---|---|---|
| order_id | Text (PK) | O-xxxxx | O-01834 | One duplicated order row |
| customer_id | Text (FK) | Links to Customers | C-032 | One or two orphan IDs |
| order_date | Date | Date received | 2026-06-14 | Mixed formats |
| dispatch_date | Date | Date shipped | 2026-06-15 | Some blank; one BEFORE order_date |
| product_id | Text (FK) | Links to Products | P-014 | Some reference Discontinued products |
| batch_id | Text (FK) | Links to Batches | B-0187 | **~15–20% blank — this is the traceability killer; make it visible** |
| quantity_sold | Integer | Units | 24 | One zero, one negative |
| sales_value | Decimal | NZD line value | 74.40 | Doesn't always equal qty × sell price (rounding/discounts — decide policy) |
| delivery_region | Text | Region delivered to | Auckland | Inconsistent naming; sometimes ≠ customer region |

## 6. Complaints

| Field | Type | Description | Example | Messy-data notes |
|---|---|---|---|---|
| complaint_id | Text (PK) | CMP-xxx | CMP-041 | — |
| customer_id | Text (FK) | Complainant | C-032 | — |
| product_id | Text (FK) | Product complained about | P-014 | A few blank ("wasn't sure which product") |
| batch_id | Text (FK) | Affected batch | B-0187 | **~30% blank — core business problem** |
| complaint_date | Date | Date received | 2026-06-20 | Mixed formats |
| complaint_type | Text | Taste/Quality, Packaging, Expiry on delivery, Foreign object, Temperature, Wrong item | Taste/Quality | Free-text variants of the same type |
| severity | Text | Low / Medium / High / Critical | Medium | "med", "HIGH" |
| complaint_status | Text | Open / In progress / Resolved / Closed | Resolved | Blanks; "Closed" vs "closed" |
| resolution_days | Integer | Days to resolve | 6 | Blank for open ones (fine) but also blank for some resolved; one negative |

## 7. Supplier Documents

| Field | Type | Description | Example | Messy-data notes |
|---|---|---|---|---|
| document_id | Text (PK) | DOC-xxx | DOC-018 | — |
| supplier_id | Text (FK) | Links to Suppliers | S-04 | — |
| document_type | Text | HACCP Cert / Food Safety Audit / Insurance / Product Spec / Temperature Declaration | HACCP Cert | Naming variants |
| issue_date | Date | Issued | 2024-09-01 | Mixed formats |
| expiry_date | Date | Expires | 2025-09-01 | **Several already expired; some blank ("doesn't expire"? decide)** |
| document_status | Text | Valid / Expired / Missing / Pending renewal | Valid | Blanks; status contradicts expiry_date on some rows |
| related_category | Text | Product category covered | Dairy | — |
| **Gap to engineer:** at least 2 suppliers should have NO row for a document type they clearly need (a missing-record problem, not a missing-value problem — much harder to find, great talking point) | | | | |

## 8. Recall Risk

| Field | Type | Description | Example | Messy-data notes |
|---|---|---|---|---|
| risk_id | Text (PK) | RR-xxx | RR-012 | — |
| batch_id | Text (FK) | Batch at risk | B-0187 | One orphan batch_id |
| risk_reason | Text | Temperature excursion / Missing docs / Complaint cluster / Failed QC / Supplier notice / Near expiry | Temperature excursion | Free-text variants |
| risk_level | Text | Low / Medium / High / Critical | High | Inconsistent casing |
| date_identified | Date | When flagged | 2026-07-01 | Mixed formats |
| action_required | Text | Hold stock / Contact customers / Chase documents / Monitor / Dispose | Hold stock | Blanks |
| status | Text | Open / In progress / Closed | Open | Blanks |

## Relationships (for your ERD — draw it yourself)

Products 1—* Batches *—1 Suppliers · Batches 1—* Orders *—1 Customers · Complaints → Customers, Products, Batches (nullable FK) · Supplier Documents *—1 Suppliers · Recall Risk *—1 Batches.

---

# Messy Data Requirements — why each issue matters

Build these into the RAW files deliberately, then document how you found and fixed each one in `cleaning_queries.sql` and the final report.

| Issue | Why it matters to the business |
|---|---|
| Missing batch numbers (batches, orders, complaints) | Breaks the traceability chain — during a recall these units are untraceable, forcing wider, costlier recalls |
| Blank expiry dates | Batch can't be classified by expiry risk; expired stock could ship undetected |
| Mixed date formats / dates as text | Date maths (days to expiry, resolution time) silently fails or errors; #1 cause of wrong dashboards |
| Inconsistent supplier names | Supplier issue counts fragment across variants — the worst supplier can hide as three "different" mediocre ones |
| Duplicate products / customers | Inflates counts, splits complaint and sales history, breaks joins |
| Complaints without batch IDs | No root cause analysis; can't detect a bad batch from complaint clustering |
| Orders against discontinued products / closed accounts | Master data drift — reference data isn't maintained, so status fields can't be trusted |
| Missing / contradictory document statuses | Compliance exposure; status columns that disagree with expiry dates mean neither can be trusted alone |
| Negative or absurd quantities | No input validation; totals and value-at-risk figures are wrong until cleaned |
| remaining > received | Physically impossible — signals missed receipts, uncounted returns, or typos; stock records unreliable |
| Expired supplier certificates | Product accepted from effectively uncertified suppliers; MPI/customer audit failure risk |
| Product name spelling variants | Product-level aggregations split; search/filter misses stock during a recall |
| Inconsistent regions | Regional recall exposure analysis fails; can't tell which delivery runs are affected |

**Cleaning deliverable:** a short data-quality log (issue → rows affected → rule applied → rows fixed/excluded). This table is often the most impressive artefact in a graduate portfolio.
