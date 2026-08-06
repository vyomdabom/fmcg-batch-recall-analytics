# DAX Measure Reference — FreshRoute Batch & Recall Analytics

Measures needed for the five pages in `dashboard_requirements.md`. Organised by page, but **create them all in one sitting** — most are reused across pages.

## How to add these

Right-click the home table in the Data pane → **New measure** → paste → Enter. The home table is cosmetic (it only affects where the measure appears in the list), but keeping measures with their source table makes the model easier to navigate.

Anything marked **column** must be created with **New column** instead — columns have row context, measures don't. If you see *"A single value for column … cannot be determined"*, you used New measure where you needed New column.

## Already built

`Total_sales` · `Sales by product` · `Sales Not Traceable` · `% Sales Not Traceable` · `Units Sold` · `Units Remaining` · `Recall Exposure Value` · `Complaints by Product` · `Stock Value at Risk` · `Expiry Window` (column) · `Expiry Window Sort` (column)

---

## Page 1 — Executive Overview

KPI cards. All straightforward counts, but note the definition choices — write them down, because a reviewer will ask what "active" means.

```DAX
Total Products = COUNTROWS ( products )
```

```DAX
Active Products =
CALCULATE ( COUNTROWS ( products ), products[active_status] = "Active" )
```

```DAX
Total Suppliers = COUNTROWS ( suppliers )
```

```DAX
Total Customers = COUNTROWS ( customers )
```

```DAX
Total Batches = COUNTROWS ( batches )
```

```DAX
Active Batches =
CALCULATE ( COUNTROWS ( batches ), batches[quantity_remaining] > 0 )
```

> **Definition choice:** "active" = still holding stock. The alternative is "not expired", which gives a different number. Pick one, use it consistently, state it on the page.

```DAX
Total Complaints = COUNTROWS ( complaints )
```

```DAX
High Risk Batches =
CALCULATE (
    DISTINCTCOUNT ( recall_risk[batch_id] ),
    recall_risk[risk_level] IN { "High", "Critical" },
    recall_risk[status] <> "Closed"
)
```

> `DISTINCTCOUNT` because one batch can have several risk records.
>
> On matching: DAX text comparisons are **case-insensitive**, so `"High"` already matches `"high"` and `"HIGH"` — casing variants won't break this. **Whitespace will.** `"High "` with a trailing space fails to match, and the data dictionary flags that pattern elsewhere in the dataset. Check with a quick table visual of `risk_level` and `status` before trusting the number; variants also appear as separate rows in slicers and legends even when they match correctly here.

---

## Page 2 — Expiry & Batch Risk

First, a column for "closest to expiry" sorting:

```DAX
Days to Expiry =                                            -- COLUMN on batches
IF (
    ISBLANK ( batches[expiry_date] ),
    BLANK (),
    INT ( batches[expiry_date] - TODAY () )
)
```

Then the measures:

```DAX
Batches Expiring 30 Days =
CALCULATE ( COUNTROWS ( batches ), batches[Expiry Window] = "0-30 days" )
```

```DAX
Stock Value Expiring 30 Days =
CALCULATE ( [Stock Value at Risk], batches[Expiry Window] = "0-30 days" )
```

```DAX
Expired Stock Value =
CALCULATE ( [Stock Value at Risk], batches[Expiry Window] = "Expired" )
```

```DAX
Batches Missing Expiry =
CALCULATE ( COUNTROWS ( batches ), batches[Expiry Window] = "Unknown" )
```

> `Batches Missing Expiry` is a requirement, not an edge case — the brief asks for missing expiry dates as an explicit "unknown" category. Put it on the page as its own card.

---

## Page 3 — Supplier Quality

This is the page that needs the most thought. Supplier reaches complaints only through `batches`, so **complaints with no `batch_id` (~46%) cannot be attributed to any supplier.** Show the coverage figure alongside the counts or the numbers will read as complete when they aren't.

```DAX
Batches Supplied = COUNTROWS ( batches )
```

```DAX
Failed QC Batches =
CALCULATE ( COUNTROWS ( batches ), batches[quality_status] = "Failed" )
```

```DAX
Failed QC Rate = DIVIDE ( [Failed QC Batches], [Batches Supplied] )
```

```DAX
Supplier Issue Rate = DIVIDE ( [Total Complaints], [Batches Supplied] )
```

> Issues per batch supplied, as the brief asks — fairer than raw counts, which just punish your highest-volume suppliers.

```DAX
Total Documents = COUNTROWS ( supplier_documents )
```

```DAX
Expired Documents =
CALCULATE (
    COUNTROWS ( supplier_documents ),
    FILTER (
        supplier_documents,
        NOT ISBLANK ( supplier_documents[expiry_date] )
            && supplier_documents[expiry_date] < TODAY ()
    )
)
```

> The blank guard matters. A blank date in DAX evaluates as earlier than today, so without it every document with no expiry date counts as expired.

```DAX
Complaints With Batch Link =
CALCULATE (
    COUNTROWS ( complaints ),
    FILTER ( complaints, NOT ISBLANK ( complaints[batch_id] ) )
)
```

```DAX
Supplier Attribution Coverage =
DIVIDE ( [Complaints With Batch Link], COUNTROWS ( ALL ( complaints ) ) )
```

### Supplier quality score — scoring method

The brief requires a scoring method that is designed and documented rather than borrowed. The model below weights four factors by **how directly each one represents a threat to the consumer**, not by how easy it is to measure.

| Weight | Factor | Rationale |
|---|---|---|
| **5** | Open recall risk | A person has already assessed this batch as hazardous and the assessment is still open. It is the only factor representing a *judged* safety threat rather than an inferred one, so it outranks everything else. |
| **4** | Expired certification | The product is effectively uncertified while still on hand. Recoverable — stock can be pulled from the shelf — but withdrawal is expensive, so it carries real cost as well as risk. |
| **2** | Document problems | Compliance and audit exposure. Serious for an MPI or customer audit, but not evidence of a specific unsafe product. |
| **1** | Complaints | A lagging quality signal. Informative and worth tracking, but a complaint is an indicator rather than proof of a hazard. |

The ladder runs: judged safety threat → recoverable cost → regulatory exposure → informational signal.

**Helper measures**

```DAX
Open Recall Risks =
CALCULATE ( COUNTROWS ( recall_risk ), recall_risk[status] <> "Closed" )
```

```DAX
Document Problems =
CALCULATE (
    COUNTROWS ( supplier_documents ),
    supplier_documents[document_status] IN { "Missing", "Incomplete", "Pending renewal" }
)
```

```DAX
Weighted Issue Points =
5 * [Open Recall Risks]
    + 4 * [Expired Documents]
    + 2 * [Document Problems]
    + 1 * [Total Complaints]
```

**The score**

```DAX
Supplier Quality Score =
VAR IssuesPerBatch = DIVIDE ( [Weighted Issue Points], [Batches Supplied] )
RETURN
MAX ( 100 - IssuesPerBatch * 20, 0 )
```

**Design notes**

- Dividing by `Batches Supplied` normalises for volume, so a high-volume supplier isn't penalised simply for supplying more. This is the same fairness principle behind `Supplier Issue Rate` in the brief.
- The `* 20` multiplier converts issues-per-batch into penalty points. It is a tuning constant, not a derived value — check the spread of real scores and adjust so that the range discriminates usefully between suppliers.
- `MAX ( …, 0 )` floors the score at zero.

**Open items**

- **Small-supplier volatility.** A supplier with 2 batches and 1 complaint produces a rate five times worse than a supplier with 40 batches and 4 complaints. Recommended: return `BLANK()` below a minimum batch count (~5) rather than publishing a noisy score. Threshold not yet set.
- **Possible double-count.** `Expired Documents` is derived from `expiry_date`; `Document Problems` is derived from `document_status`. The data dictionary notes these two fields contradict each other on some rows, so one document can attract both a 4 and a 2. Decide whether to accept this or make the two factors mutually exclusive.

---

## Page 5 — Customer Complaints

```DAX
Open Complaints =
CALCULATE (
    COUNTROWS ( complaints ),
    complaints[complaint_status] IN { "Open", "In progress" }
)
```

```DAX
Critical Complaints =
CALCULATE ( COUNTROWS ( complaints ), complaints[severity] = "Critical" )
```

```DAX
Avg Resolution Days =
CALCULATE (
    AVERAGE ( complaints[resolution_days] ),
    complaints[resolution_days] >= 0
)
```

> The `>= 0` filter excludes CMP-021, which has −3 resolution days. Without it one bad row drags the average. Blanks are ignored by `AVERAGE` automatically, which is correct for unresolved complaints — but note that your cleaning log found blanks on some *resolved* ones too, so this average covers only complaints with a valid recorded duration.

```DAX
Complaints Without Batch =
CALCULATE (
    COUNTROWS ( complaints ),
    FILTER ( complaints, ISBLANK ( complaints[batch_id] ) )
)
```

```DAX
% Complaints Without Batch =
DIVIDE ( [Complaints Without Batch], [Total Complaints] )
```

> Format as a percentage. This is the headline traceability metric for complaints — the counterpart to `% Sales Not Traceable` on the orders side. Both belong on Page 1 as well.

---

## Formatting

Set these once in **Measure tools** and they apply everywhere:

| Measure type | Format |
|---|---|
| `Total_sales`, `Stock Value at Risk`, `Recall Exposure Value`, `Expired Stock Value` | Currency, 0 dp |
| `% Sales Not Traceable`, `% Complaints Without Batch`, `Failed QC Rate`, `Supplier Attribution Coverage` | Percentage, 1 dp |
| `Supplier Issue Rate`, `Avg Resolution Days`, `Supplier Quality Score` | Decimal, 1 dp |
| All counts | Whole number, thousands separator |

## Data-quality caveats to carry onto the pages

- **Batch B-0026** has `quantity_received` of 48,000 against a plausible max of ~960. It will distort `Stock Value at Risk` in whichever expiry bucket it lands in. Decide whether to exclude it and record the decision.
- **Batch B-0011** has `quantity_received` of −120.
- **Five batches** have `quantity_remaining` greater than `quantity_received`.
- **Supplier attribution** covers only complaints that have a batch link (~54%).
- **Synthetic-data limits** (D1–D3) are recorded in `ba-documents/assumptions_risks_constraints.md` — stock reconciliation and dispatch-vs-manufacture checks are not meaningful on this dataset.
