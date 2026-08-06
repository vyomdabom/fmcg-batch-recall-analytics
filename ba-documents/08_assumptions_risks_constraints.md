# Assumptions, Risks and Constraints

**FreshRoute Foods Ltd — Batch and Recall Risk Analytics**

Prepared by: Vyom Patel
Date: 5 August 2026

---

## Assumptions

Assumptions are stated with their impact if wrong, because an assumption without a consequence is just a note. Where an assumption remains unconfirmed, the requirement or recommendation it affects is identified so it can be challenged by the person best placed to correct it.

| # | Assumption | Impact if wrong | Affects | Status |
|---|---|---|---|---|
| A1 | Warehouse staff can capture batch numbers at goods in without significant slowdown | Data capture fails at source and the whole model degrades. This is the central assumption behind R1. | BR-01, R1 | Unconfirmed |
| A2 | Suppliers can provide batch, expiry and certification data in usable form | The document register has permanent gaps that no internal process can close | BR-07, R7 | Unconfirmed |
| A3 | All five supplier document types are required for every supplier | If some apply only to certain supplier categories, the 52% documentation gap overstates the problem and R7 drops in priority | BR-07, R7 | Open, raised as Q33 |
| A4 | Recall risks marked "In progress" should be treated as open | A stricter reading reduces the recall risk counts in the supplier ranking and changes the relative order of suppliers | BR-06 | Assumed, documented |
| A5 | Unit costs held in the product table are current | All value at risk and recall exposure figures are proportionally wrong. Direction of findings unchanged, magnitude affected. | BR-02, BR-04 | Unconfirmed |
| A6 | Orders with no batch identifier are permanently unattributable | If a reliable inference method exists, exposure figures are understated and could be improved. The project treats inference as unsafe. | BR-01, BR-13 | Deliberate decision |
| A7 | The manual recall baseline of 6.5 hours is representative | The headline improvement claim is proportionally wrong, though the reproducibility argument stands regardless of timing | Report Section 6 | Single observation |
| A8 | Quantity remaining reflects physical stock on hand | Value at risk and recall exposure are calculated on inventory that may not exist. See D2 below. | BR-04, BR-05 | Known to be imperfect |

**On A7.** The 6.5 hour baseline comes from one recorded recall, not a measured average. It is the weakest number in the report and is flagged as indicative in the process maps. The stronger claim is not the time saved but that the result became reproducible.

---

## Risks

Likelihood and impact rated Low, Medium or High. Score is the product, treating Low as 1, Medium as 2 and High as 3.

| # | Risk | Likelihood | Impact | Score | Mitigation | Threatens |
|---|---|---|---|---|---|---|
| R1 | Staff bypass the new process under time pressure and revert to spreadsheets | Med | High | 6 | Make the batch field mandatory rather than encouraged, so bypassing requires an explicit reason code. Visible sponsorship from the GM, since the cost falls on the warehouse while the benefit accrues during rare recalls. | BR-01, BR-15 |
| R2 | Historic data too incomplete to establish reliable baselines | Med | Med | 4 | Report all counts as floors. Measure improvement forward from implementation rather than against a historic baseline. | BR-13 |
| R3 | Supplier document management depends on one person | Med | Med | 4 | Maintain the document register as a shared artefact with expiry dates, so currency is visible without relying on individual recall. | BR-07, R7 |
| R4 | Dashboard figures drift from SQL as either is modified | High | Med | 6 | Fixed reporting date applied in both. Filter definitions documented. Reconciliation check added to the definition of done. | BR-19, US-19 |
| R5 | Risk scoring model treated as authoritative despite known blind spots | Med | High | 6 | Document explicitly that the model scored the live recall batch at 3 of 12 and missed it. Do not adopt the model before R2 closes the input gap. | BR-09 |
| R6 | Findings acted on without the stated caveats | Med | High | 6 | State limitations in the section where each finding appears rather than only in an appendix. Describe affected counts as floors in the text itself. | BR-13, BR-17 |
| R7 | Recommendations approved but never resourced | Med | Med | 4 | Sequence recommendations by effort as well as impact, so the three low effort items can proceed without a business case. | All recommendations |
| R8 | Supplier analysis damages relationships if presented without context | Low | High | 3 | Rank by rate rather than raw volume. State explicitly that the evidence does not support changing supplier over the recall. | BR-06 |
| R9 | Validation rules at goods in are relaxed after operational complaints | Med | Med | 4 | Separate hard rejects for impossible values from soft warnings for implausible ones, so legitimate exceptions are not blocked. | BR-16, R3 |

**Highest scoring risks are R1, R4, R5 and R6, all at 6.** Three of the four are about how the work is used rather than how it was built. A correct analysis that is misread, drifts out of sync, or gets bypassed in practice delivers nothing, and those failure modes are less visible than analytical errors.

---

## Constraints

| # | Constraint | Consequence for the solution |
|---|---|---|
| C1 | SME budget. No ERP or WMS purchase in scope. | The solution must work with Excel, SQL and Power BI. Recommendations are process and validation changes rather than system replacement. |
| C2 | Small team. Improvements must not add significant daily admin. | Recommendations favour one-off validation rules and scheduled reports over continuous manual monitoring. |
| C3 | NZ Food Act and MPI traceability expectations form a compliance floor. | Traceability is not optional or a matter of efficiency alone. Reproducibility and auditability are requirements, not refinements. |
| C4 | No changes to operational source systems within this project. | The analysis works with the data those systems produce. System changes arising from R1 and R3 are a separate initiative. |
| C5 | Analysis performed against a point in time extract, not a live connection. | All figures carry an as-at date. The dashboard is a monitoring tool on a refreshed extract, not a real time system. |
| C6 | Single analyst, no peer review available during the project. | Verification relies on internal consistency checks: reconciling SQL against dashboard, and testing detection logic against known-bad records rather than trusting empty results. |

**On C6.** This constraint shaped the method more than any other. An orphan check returning no rows is indistinguishable from a broken orphan check, so detection logic was verified against records known to be orphans before empty results were accepted. Without a reviewer, the checks have to check themselves.

---

## Dataset limitations (synthetic data)

The dataset is generated by `data/generate_raw_data.py`. Most data-quality issues in it are **deliberate** (missing batch IDs, mixed date formats, duplicate products, expired certificates) and are the subject of the analysis. The items below are **incidental** — side effects of how the generator assigns orders to batches — and should not be read as business findings.

| # | Limitation | Cause | Consequence for analysis |
|---|---|---|---|
| D1 | Orders are linked to a random batch of the correct product, with no date constraint | `generate_raw_data.py` line 248 selects a batch independently of `order_date` | 53.8% of batch-linked orders have a dispatch date earlier than their batch's `manufacture_date`. Dispatch-vs-manufacture and shipped-after-expiry checks are not meaningful on this dataset. |
| D2 | No per-batch quantity budget is enforced when generating orders | Order quantities are drawn independently of `quantity_received` | 63 of 291 linked batches (21.6%) have `quantity_sold + quantity_remaining > quantity_received`, totalling ~8,254 phantom units. Stock reconciliation cannot be used as a data-quality measure. |
| D3 | The mock recall batch B-0187 carries incidental orders alongside its designed ones | 14 scenario orders (10 Jun – 5 Jul 2026) are added deliberately; the main loop also assigned ~8 random orders to the same batch | Page 4 shows 22 order lines / 534 units for `YD-2408-A` rather than the ~14 lines intended by `mock_recall_scenario.md`. The traceability logic is correct; the volume is inflated. |

**Verified unaffected:** the traceability gap that this project exists to measure is engineered deliberately and holds up — 316 of 1,796 orders (17.6%) have no `batch_id`, confirmed independently in Power BI as NZ$53,866.42 of untraceable sales (17.6% of NZ$305,222.65). Complaint-level gaps (~46% without `batch_id`) are likewise deliberate.

**Decision:** documented rather than corrected. Fixing D1/D2 would require regenerating the raw data and re-running the clean/import chain, which would invalidate the existing `import_log.md` and data-quality log for no gain to the questions this project answers.

---

## Risk to requirement traceability

| Requirement | Threatened by | Highest scoring threat |
|---|---|---|
| BR-01 Trace a batch to its customers | R1 | 6 |
| BR-02 Quantify recall exposure | A5, A8 | Assumption risk |
| BR-04 Stock value at risk | A5, A8, D2 | Assumption and dataset limitation |
| BR-06 Rank suppliers | A4, R8 | 3 |
| BR-07 Supplier documentation | A2, A3, R3 | 4 |
| BR-09 Batch risk scoring | R5 | 6 |
| BR-13 Data completeness | R2, R6 | 6 |
| BR-15 Reproducibility | R1 | 6 |
| BR-16 Referential integrity | R9 | 4 |
| BR-19 Fixed reporting date | R4 | 6 |

---

## Note

FreshRoute Foods Ltd is a fictional company created for this case study. Assumptions and risks reflect the simulated scenario.
