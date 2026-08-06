# Business Requirements

**FreshRoute Foods Ltd — Batch and Recall Risk Analytics**

Prepared by: Vyom Patel
Date: 5 August 2026

---

## Purpose and scope

This document sets out the requirements for the batch and recall risk analytics solution. Requirements are numbered for traceability and cross referenced to the business questions they answer, the user stories that express them, and the deliverables that satisfy them.

Requirements are classified using MoSCoW:

- **Must** — the solution fails its purpose without this
- **Should** — important, but the solution is still useful without it
- **Could** — desirable if effort allows
- **Won't** — explicitly out of scope for this phase

Priority reflects value to the business, not difficulty to build.

---

## Requirement summary

| ID | Requirement | Type | Priority | Status |
|---|---|---|---|---|
| BR-01 | Trace a batch to all customers who received it | Functional | Must | Delivered |
| BR-02 | Quantify total recall exposure for a batch | Functional | Must | Delivered |
| BR-03 | Identify complaints already linked to a batch | Functional | Must | Delivered |
| BR-04 | Report stock value at risk by expiry window | Functional | Must | Delivered |
| BR-05 | Identify stock already past expiry with quantity on hand | Functional | Must | Delivered |
| BR-06 | Rank suppliers by quality issues from multiple sources | Functional | Should | Delivered |
| BR-07 | Identify batches from suppliers with missing documentation | Functional | Should | Delivered |
| BR-08 | Report complaint rates normalised by sales volume | Functional | Should | Delivered |
| BR-09 | Score batches by composite risk | Functional | Should | Delivered |
| BR-10 | Report complaint resolution performance | Functional | Could | Delivered |
| BR-11 | Identify products and storage types concentrating expiry risk | Functional | Should | Delivered |
| BR-12 | Identify warehouse locations concentrating expiry risk | Functional | Could | Delivered |
| BR-13 | Quantify and report data completeness | Non-functional | Must | Delivered |
| BR-14 | Preserve all source records, including invalid ones | Non-functional | Must | Delivered |
| BR-15 | Produce reproducible results | Non-functional | Must | Delivered |
| BR-16 | Enforce referential integrity | Non-functional | Must | Delivered |
| BR-17 | Document all analytical assumptions | Non-functional | Must | Delivered |
| BR-18 | Present findings for a non-technical audience | Non-functional | Must | Delivered |
| BR-19 | Support a fixed reporting date | Non-functional | Should | Delivered |
| BR-20 | Allow batch selection without rebuilding the report | Non-functional | Should | Delivered |

---

## Functional requirements

### BR-01 — Trace a batch to all customers who received it

**Requirement.** Given a batch number, the solution must return every customer that received stock from that batch, together with quantity dispatched, dispatch date, delivery region and contact details.

**Rationale.** This is the core capability. The manual process took 6.5 hours and depended on individual judgement.

**Answers business question:** 5
**Satisfied by:** `sql/recall_traceability_query.sql`; Recall Traceability dashboard page
**Related user story:** US-01

**Acceptance:** Returns the complete set of orders carrying the batch identifier, in under one minute, with identical results on repeat execution.

**Known limitation.** Orders with no batch identifier cannot be traced. The result is complete for linked orders and is a floor, not a full count. This limitation must be stated wherever the result is presented (see BR-13).

---

### BR-02 — Quantify total recall exposure for a batch

**Requirement.** The solution must report the financial exposure of a recall, separated into value already dispatched to customers and value of stock still held.

**Rationale.** The two figures answer different business questions. Dispatched value represents potential refunds and reputational exposure; stock on hand is a direct write off that can be actioned immediately. Reporting only a combined total obscures the distinction.

**Answers business question:** 7
**Satisfied by:** `sql/recall_traceability_query.sql`; Recall Traceability dashboard page
**Related user story:** US-02

**Acceptance:** Both components reported separately and as a total. Values must not be inflated by fan-out when joining batch level data to order level data.

---

### BR-03 — Identify complaints already linked to a batch

**Requirement.** When tracing a batch, the solution must surface any existing customer complaints associated with that batch, including status and date raised.

**Rationale.** An open complaint against a batch is an early warning. In the tested scenario, complaint CMP-099 had been open against the recall batch for three weeks before the supplier notice arrived, and no process connected the two.

**Answers business question:** 8
**Satisfied by:** `sql/recall_traceability_query.sql`; Recall Traceability dashboard page
**Related user story:** US-03

**Acceptance:** Complaints linked to the batch are returned as part of the trace, not as a separate manual lookup.

---

### BR-04 — Report stock value at risk by expiry window

**Requirement.** The solution must report the number of batches and total stock value falling into defined expiry windows: already expired, 0 to 30 days, 31 to 60 days, and 61 to 90 days.

**Rationale.** Exposure and urgency are different. Stock expiring within 30 days requires a decision now; stock at 90 days is a planning input. Reporting a single total prevents that distinction.

**Answers business questions:** 1, 2
**Satisfied by:** `sql/analysis_queries.sql` C7, C8; Expiry and Batch Risk dashboard page
**Related user story:** US-04

**Acceptance:** Windows are mutually exclusive and collectively exhaustive. Batches with no expiry date are reported separately rather than silently excluded. Only batches with stock on hand are counted, since stock no longer held is not at risk.

---

### BR-05 — Identify stock already past expiry with quantity on hand

**Requirement.** The solution must list batches whose expiry date has passed but which still show units in stock, with days overdue and value.

**Rationale.** This is loss already incurred but not yet recognised. It also means reported stock on hand overstates sellable inventory.

**Answers business question:** 1
**Satisfied by:** `sql/analysis_queries.sql` C8; `sql/cleaning_queries.sql` B5
**Related user story:** US-05

**Acceptance:** Days overdue reported per batch. Total value reported. Result agrees with the expiry window report.

---

### BR-06 — Rank suppliers by quality issues from multiple sources

**Requirement.** The solution must rank suppliers by total quality issues, combining failed quality control checks, batch linked complaints, and open recall risks, with a breakdown by source.

**Rationale.** A single combined score hides the profile. A supplier with many complaints and no QC failures presents a different risk from one with the reverse.

**Answers business question:** 9
**Satisfied by:** `sql/analysis_queries.sql` C11; Supplier Quality dashboard page
**Related user story:** US-06

**Acceptance:** Breakdown by issue type shown alongside the total. Suppliers with zero issues remain visible rather than dropping out. Rate per batch supplied reported alongside raw counts, so large suppliers are not penalised for volume.

---

### BR-07 — Identify batches from suppliers with missing documentation

**Requirement.** The solution must identify which required supplier document types are missing or expired, and which batches originate from the affected suppliers.

**Rationale.** Documentation gaps are an audit exposure. Linking them to batches shows how much stock is affected rather than only how many documents are outstanding.

**Answers business question:** 10
**Satisfied by:** `sql/analysis_queries.sql` C9; Supplier Quality dashboard page
**Related user story:** US-07

**Acceptance:** Absence is detected, not merely presence counted. A supplier who has never supplied a document type must be identified, which requires comparing against an expected set rather than reporting on records that exist.

---

### BR-08 — Report complaint rates normalised by sales volume

**Requirement.** The solution must report complaints per 1,000 units sold by product, alongside raw complaint counts.

**Rationale.** Raw counts reward low volume products and penalise popular ones. Normalising changed the ranking materially in practice.

**Answers business question:** 12
**Satisfied by:** `sql/analysis_queries.sql` C10; Customer Complaints dashboard page
**Related user story:** US-08

**Acceptance:** Products with zero complaints retained in the output. Rate calculated using decimal arithmetic, since integer division truncates and produces misleading whole numbers.

---

### BR-09 — Score batches by composite risk

**Requirement.** The solution must assign each batch a risk score derived from weighted, additive factors: open recall risk, expired status, documentation problems and existing complaints. Weights must be documented and adjustable.

**Rationale.** Risk is currently assessed case by case. A transparent scoring model makes assessment repeatable and reviewable.

**Answers business question:** 11
**Satisfied by:** `sql/analysis_queries.sql` C12; Executive Overview dashboard page
**Related user story:** US-09

**Acceptance:** Factors are additive rather than filtering, so a batch with one severe problem is not excluded for lacking others. Weights are stated in the query and owned by Quality as a business decision.

**Known limitation.** The model can only see risks recorded in the system. In testing it scored the live recall batch at 3 of a possible 12 and did not rank it, because the supplier notification had never been logged. The weights were sound; the input was missing. This is addressed by recommendation R2 rather than by recalibration.

---

### BR-10 — Report complaint resolution performance

**Requirement.** The solution must report average resolution time by severity and complaint type, with the count of complaints in each group, and the number of complaints still open.

**Rationale.** Averages without counts are misleading. A category averaging 18 days from a single complaint is an anecdote, not a pattern.

**Answers business question:** 14
**Satisfied by:** `sql/analysis_queries.sql` C13; Customer Complaints dashboard page
**Related user story:** US-10

**Acceptance:** Group size reported alongside every average. Records with impossible values, such as negative resolution days, excluded and the exclusion documented.

---

### BR-11 — Identify products and storage types concentrating expiry risk

**Requirement.** The solution must report near expiry stock value grouped by product and by storage type.

**Rationale.** If exposure is concentrated, targeted action is far more efficient than a warehouse wide programme. In practice three products accounted for close to half of total exposure.

**Answers business question:** 3
**Satisfied by:** `sql/analysis_queries.sql` C8 variants; Expiry and Batch Risk dashboard page
**Related user story:** US-11

**Acceptance:** Grouped totals reconcile to the overall expiry figure, confirming the same population is being reported.

---

### BR-12 — Identify warehouse locations concentrating expiry risk

**Requirement.** The solution must report at risk stock value by warehouse location.

**Rationale.** A physical stock review is faster if it can be targeted to specific aisles rather than the full warehouse.

**Answers business question:** 4
**Satisfied by:** Expiry and Batch Risk dashboard page
**Related user story:** US-12

**Acceptance:** Locations ranked by value, with batch count and units remaining shown.

---

## Non-functional requirements

### BR-13 — Quantify and report data completeness

**Requirement.** The solution must measure and report the proportion of records missing critical identifiers, and every finding affected by those gaps must state the limitation.

**Rationale.** With 17.6% of orders and 46% of complaints lacking a batch identifier, results that ignore this would appear authoritative on an incomplete base. A stated limitation can be challenged; a hidden one cannot.

**Answers business question:** 15
**Satisfied by:** `sql/cleaning_queries.sql` B6; Report Sections 2 and 8
**Related user story:** US-13

**Acceptance:** Completeness reported as both count and percentage. Every dependent finding is explicitly described as a floor rather than a full count.

---

### BR-14 — Preserve all source records, including invalid ones

**Requirement.** Records failing validation must be quarantined in exceptions tables rather than deleted. Every exclusion must be documented and reversible.

**Rationale.** Deleting bad records destroys evidence of the data quality problem the project exists to address, and makes the analysis impossible to audit.

**Satisfied by:** `sql/create_tables.sql` exceptions tables; `data/cleaned/csv/` exception files; Report Section 8
**Related user story:** US-14

**Acceptance:** Row counts reconcile between source and destination, with every difference accounted for by a documented exception.

---

### BR-15 — Produce reproducible results

**Requirement.** Running the same analysis against the same data must produce identical results regardless of who runs it.

**Rationale.** The manual process depended on judgement, so two people could produce different customer lists from the same recall. Reproducibility is what makes a trace defensible.

**Satisfied by:** Version controlled SQL; documented exclusion rules; fixed reporting date
**Related user story:** US-15

**Acceptance:** No step requires operator judgement. All exclusions are encoded in the query, not applied by hand.

---

### BR-16 — Enforce referential integrity

**Requirement.** The database must enforce primary and foreign key relationships and apply constraints preventing impossible values.

**Rationale.** Integrity enforced at the database level prevents silent corruption. Orphan records that existed in the source must be identified before load rather than discovered later.

**Satisfied by:** `sql/create_tables.sql`; `sql/cleaning_queries.sql` B4
**Related user story:** US-16

**Acceptance:** All foreign key relationships enforced. Orphan checks return no unexpected results, and detection is verified using a known-bad control rather than assumed to work because it returned nothing.

---

### BR-17 — Document all analytical assumptions

**Requirement.** Every assumption materially affecting a result must be stated in the deliverable that presents it.

**Rationale.** An assumption buried in a query cannot be challenged by the business owner who is best placed to correct it.

**Satisfied by:** Query comments; Report Section 8; Recommendations dependencies
**Related user story:** US-17

**Acceptance:** Assumptions stated with their impact if incorrect, not merely listed.

---

### BR-18 — Present findings for a non-technical audience

**Requirement.** The primary deliverable must be readable by an operations or general management audience, with technical evidence referenced rather than embedded.

**Rationale.** Findings that require SQL literacy to interpret will not be acted on by the people who own the processes.

**Satisfied by:** Final Insights Report; Power BI dashboard
**Related user story:** US-18

**Acceptance:** No SQL in the report body. Every figure paired with its business meaning rather than presented alone.

---

### BR-19 — Support a fixed reporting date

**Requirement.** All date dependent calculations must reference a single, explicitly stated reporting date rather than the current system date.

**Rationale.** Expiry classifications shift as time passes, so results computed on different days disagree. In testing, three batches that appeared as future dated on 17 July no longer did so by 31 July. Without a fixed date, the report and dashboard cannot be reconciled.

**Satisfied by:** Date literals in SQL; fixed date measure in the dashboard; stated as-at date in the report
**Related user story:** US-19

**Acceptance:** Reporting date stated once and applied consistently. Report figures and dashboard figures agree exactly.

---

### BR-20 — Allow batch selection without rebuilding the report

**Requirement.** The recall trace must allow any batch to be selected interactively, without editing a query.

**Rationale.** A recall coordinator should not need SQL access to run a trace. The capability is only useful if it is available at the moment it is needed.

**Satisfied by:** Batch slicer on the Recall Traceability dashboard page
**Related user story:** US-20

**Acceptance:** Selecting a different batch updates all figures on the page consistently.

---

## Explicitly out of scope

| ID | Excluded | Reason |
|---|---|---|
| BR-X1 | Modifying operational source systems | This project analyses data those systems produce. System change is a separate initiative arising from recommendations R1 and R3. |
| BR-X2 | Retrospectively assigning batch identifiers to historical orders | An inferred link is worse than an acknowledged blank, because it looks like data while being a guess. |
| BR-X3 | Real time or automated alerting | The solution supports scheduled review, not event driven notification. |
| BR-X4 | Demand forecasting or reorder point calculation | Outside the traceability and risk scope. |
| BR-X5 | Supplier contract or commercial terms analysis | Data not available and outside scope. |

---

## Traceability matrix

| Business question | Requirement | Deliverable |
|---|---|---|
| 1. Batches expiring within 30/60/90 days | BR-04, BR-05 | C7, C8; Expiry dashboard |
| 2. Stock value at risk per window | BR-04 | C8; Expiry dashboard |
| 3. Products and storage types with most near-expiry stock | BR-11 | C8 variants; Expiry dashboard |
| 4. Warehouse locations holding risky stock | BR-12 | Expiry dashboard |
| 5. Customers who received an affected batch | BR-01 | D14; Recall dashboard |
| 6. Regions most exposed during a recall | BR-01 | D14; Recall dashboard |
| 7. Customers affected and total exposure value | BR-02 | D14; Recall dashboard |
| 8. Complaints already linked to the affected batch | BR-03 | D14; Recall dashboard |
| 9. Suppliers with the most quality issues | BR-06 | C11; Supplier dashboard |
| 10. Batches with missing or expired supplier documents | BR-07 | C9; Supplier dashboard |
| 11. Suppliers to prioritise for review | BR-06, BR-09 | C11, C12; Recommendations |
| 12. Products receiving the most complaints | BR-08 | C10; Complaints dashboard |
| 13. Complaint trend and over-representation | BR-08, BR-13 | C10; Complaints dashboard |
| 14. Average resolution time and open complaints | BR-10 | C13; Complaints dashboard |
| 15. Share of records missing batch identifiers | BR-13 | B6; Report Sections 2 and 8 |
| 16. Process improvements in priority order | All | Recommendations; Process Maps |

---

## Note

FreshRoute Foods Ltd is a fictional company created for this case study. Requirements were derived from the simulated scenario and refined during the analysis.
