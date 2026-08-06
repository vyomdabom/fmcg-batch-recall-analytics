# Acceptance Criteria

**FreshRoute Foods Ltd — Batch and Recall Risk Analytics**

Prepared by: Vyom Patel
Date: 5 August 2026

---

## Purpose

Acceptance criteria define what "done" means for each user story. They are written in Given/When/Then form so that each one is testable: a criterion that cannot be verified is a preference, not a criterion.

Where a criterion was verified during the project, the result is recorded. All verification was performed against the dataset as at 31 July 2026.

---

## Epic 1: Recall traceability

### US-01 — Trace a batch to its customers

**AC-01.1**
> **Given** a batch number for a batch that has been dispatched
> **When** the recall trace is run
> **Then** every customer who received stock from that batch is returned, with quantity dispatched, dispatch date, delivery region and contact person

*Verified: batch YD-2408-A returned 18 customers across 22 orders in 6 regions.*

**AC-01.2**
> **Given** the same batch number
> **When** the trace is run a second time, by a different person
> **Then** the result is identical

*Verified: no step depends on operator judgement.*

**AC-01.3**
> **Given** a batch that has never been dispatched
> **When** the trace is run
> **Then** an empty result is returned rather than an error

**AC-01.4**
> **Given** orders exist that carry no batch identifier
> **When** the trace is run
> **Then** those orders are excluded from the result, and the limitation is stated wherever the result is presented

*Verified: 17.6% of orders carry no batch identifier. Stated in Report Section 6 as an explicit floor.*

**AC-01.5**
> **Given** a trace is required during a live incident
> **When** the trace is run
> **Then** results are available in under one minute

*Verified: under one minute, against a manual baseline of 6.5 hours.*

---

### US-02 — Understand the financial exposure of a recall

**AC-02.1**
> **Given** a batch with both dispatched and remaining stock
> **When** exposure is calculated
> **Then** dispatched value and stock on hand value are reported separately as well as combined

*Verified: $3,205.55 dispatched, $503.12 on hand, $3,708.67 total.*

**AC-02.2**
> **Given** a batch has multiple associated orders
> **When** stock on hand value is calculated
> **Then** the remaining quantity is counted once, not multiplied across the orders

*This is the fan-out trap. Joining a single batch record to 22 order records would repeat the remaining quantity 22 times and overstate on hand value by more than twentyfold. The two components are therefore calculated in separate queries.*

**AC-02.3**
> **Given** a batch with no remaining stock
> **When** exposure is calculated
> **Then** on hand value returns zero rather than null or an error

---

### US-03 — See existing complaints against a recalled batch

**AC-03.1**
> **Given** a batch with one or more complaints logged against it
> **When** the trace is run
> **Then** those complaints are returned with type, severity, date raised and status

*Verified: batch B-0187 returned complaint CMP-099, Taste/Quality, Medium severity, raised 6 July 2026, status open.*

**AC-03.2**
> **Given** a complaint predates the recall notification
> **When** it is displayed
> **Then** the date raised is shown so the sequence of events is visible

**AC-03.3**
> **Given** complaints exist that carry no batch identifier
> **When** the trace is run
> **Then** they are not returned, and the limitation is stated

*46% of complaints carry no batch identifier and cannot be attributed to any batch.*

---

### US-20 — Select any batch without technical help

**AC-20.1**
> **Given** the recall dashboard page is open
> **When** a user selects a different batch from the slicer
> **Then** all figures on the page update consistently to reflect the selected batch

**AC-20.2**
> **Given** a user without database access
> **When** they need to run a trace
> **Then** they can do so through the dashboard without writing or editing a query

---

### US-06b — Know which affected customers cannot be contacted

**AC-06b.1**
> **Given** an affected customer has no contact person recorded
> **When** the trace is run
> **Then** the customer still appears in the result, with the missing field visible rather than the row omitted

*Verified: Addington Espresso Bar (C-016) appears in the trace with a blank contact person.*

---

## Epic 2: Expiry and stock risk

### US-04 — See stock approaching expiry

**AC-04.1**
> **Given** the reporting date
> **When** the expiry report is produced
> **Then** batches are grouped into expired, 0 to 30 days, 31 to 60 days and 61 to 90 days, with batch count and stock value for each

*Verified: 21 / 13 / 15 / 11 batches and $9,961.49 / $8,542.38 / $13,103.95 / $6,355.46 respectively.*

**AC-04.2**
> **Given** a batch has no units remaining
> **When** the expiry report is produced
> **Then** it is excluded, because stock no longer held is not at risk

**AC-04.3**
> **Given** a batch has no expiry date recorded
> **When** the expiry report is produced
> **Then** it is reported separately as unknown rather than silently omitted

*Verified: 3 batches with stock and no expiry date are reported as Unknown.*

**AC-04.4**
> **Given** the expiry windows are defined
> **When** any batch is classified
> **Then** it falls into exactly one window

**AC-04.5**
> **Given** a batch is known to contain a corrupted quantity
> **When** value at risk is calculated
> **Then** it is excluded and the exclusion is documented

*Verified: batch B-0026, recorded at 48,000 units against a plausible maximum near 960, excluded and documented.*

---

### US-05 — Identify stock already past expiry

**AC-05.1**
> **Given** the reporting date
> **When** the expired stock report is produced
> **Then** batches past expiry with units remaining are listed with days overdue and value

*Verified: 21 batches, $9,961.49, with the oldest 156 days past expiry.*

**AC-05.2**
> **Given** the expired stock report and the expiry window report
> **When** both are produced
> **Then** the expired figures agree between them

---

### US-11 — Know which products drive expiry risk

**AC-11.1**
> **Given** near expiry stock exists
> **When** it is grouped by product
> **Then** products are ranked by value at risk, with batch count shown

*Verified: top product Cream 300ml at $7,864.04 across 7 batches.*

**AC-11.2**
> **Given** near expiry stock exists
> **When** it is grouped by storage type
> **Then** each storage type is reported with batch count and value

*Verified: Chilled 42 batches / $31,416.14; Ambient 18 batches / $6,547.14.*

**AC-11.3**
> **Given** the same population is grouped different ways
> **When** the groupings are totalled
> **Then** each grouping sums to the same overall figure

*Verified: both groupings total 60 batches and $37,963.28.*

---

### US-12 — Target a physical stock review

**AC-12.1**
> **Given** at risk stock exists across multiple locations
> **When** the location report is produced
> **Then** locations are ranked by value at risk, with batch count and units remaining

*Verified: top location C2-A3, 2 batches, 533 units, $1,897.48.*

---

## Epic 3: Supplier quality

### US-06 — Rank suppliers by quality issues

**AC-06.1**
> **Given** quality issues exist across three sources
> **When** the supplier ranking is produced
> **Then** each supplier shows a total and a breakdown by failed QC, complaints and recall risks

*Verified: 14 suppliers ranked; top is Kereru Organics with 10 issues (2 QC, 7 complaints, 1 recall).*

**AC-06.2**
> **Given** suppliers differ in the number of batches they supply
> **When** the ranking is produced
> **Then** issues per batch supplied is reported alongside raw counts

*Without normalisation the largest supplier appears worst simply for supplying more. Meadow Valley has the most batches at 53 and one of the lowest issue rates at 0.11.*

**AC-06.3**
> **Given** a supplier has no recorded issues
> **When** the ranking is produced
> **Then** they still appear, rather than dropping out of the result

**AC-06.4**
> **Given** complaints exist with no batch identifier
> **When** the ranking is produced
> **Then** the counts are described as a floor rather than a complete tally

---

### US-07 — See which batches came from under documented suppliers

**AC-07.1**
> **Given** a set of required document types
> **When** the documentation report is produced
> **Then** document types a supplier has never provided are identified, not only those that exist and have expired

*Detecting absence requires comparing against an expected set. A query over existing records can only find expired documents, never missing ones.*

**AC-07.2**
> **Given** a supplier is missing a required document
> **When** the report is produced
> **Then** the batches supplied by that supplier are identified

*Verified: 156 of 298 batches (52%) originate from suppliers missing at least one document type.*

**AC-07.3**
> **Given** the required document set is an assumption
> **When** the finding is presented
> **Then** the assumption is stated with its impact if incorrect

---

### US-09 — See which batches are highest risk

**AC-09.1**
> **Given** the defined risk factors and weights
> **When** a batch is scored
> **Then** the score is the sum of all applicable factors

**AC-09.2**
> **Given** a batch meets one risk factor but not others
> **When** scoring is applied
> **Then** it still receives a score, rather than being excluded for failing to meet all factors

*Scoring conditions must be additive expressions, not filters. A filter requiring every condition would return only batches with all four problems simultaneously, which is not what risk scoring means.*

**AC-09.3**
> **Given** the weights are a business decision
> **When** the model is documented
> **Then** each weight is stated with the reasoning behind it

**AC-09.4**
> **Given** a risk exists but has not been recorded in the system
> **When** scoring is applied
> **Then** the model cannot detect it, and this limitation is documented

*Verified as a genuine failure: the live recall batch scored 3 of a possible 12 and did not rank in the top ten, because the supplier notification had never been entered into the recall risk register.*

---

## Epic 4: Complaints

### US-08 — Compare complaint rates fairly across products

**AC-08.1**
> **Given** complaints and sales volumes by product
> **When** the rate is calculated
> **Then** complaints per 1,000 units sold is reported alongside the raw count

*Verified: top rate Nut Bar Almond 45g at 4.98 per 1,000 units.*

**AC-08.2**
> **Given** the rate calculation involves division
> **When** it is computed
> **Then** decimal arithmetic is used

*Integer division truncates and returns whole numbers, which silently changes the ranking.*

**AC-08.3**
> **Given** a product has no complaints
> **When** the report is produced
> **Then** it appears with a rate of zero rather than being omitted

**AC-08.4**
> **Given** complaints exist with no product identifier
> **When** the report is produced
> **Then** they are excluded from rate calculations and the exclusion is stated

*5 complaints have no product identifier.*

---

### US-10 — Understand complaint resolution performance

**AC-10.1**
> **Given** resolved complaints exist
> **When** average resolution time is reported by severity and type
> **Then** the number of complaints behind each average is shown alongside it

*An average of 18.0 days derived from a single complaint is an anecdote. Without the count it reads as a pattern.*

**AC-10.2**
> **Given** a complaint records an impossible resolution time
> **When** averages are calculated
> **Then** it is excluded and the exclusion is documented

*Verified: complaint CMP-021, recording −3 resolution days, excluded.*

**AC-10.3**
> **Given** complaints remain unresolved
> **When** the report is produced
> **Then** the count of open complaints is reported separately from resolution averages

*Verified: 28 of 100 complaints open.*

---

## Epic 5: Data quality and trust

### US-13 — Know how much of the data can be trusted

**AC-13.1**
> **Given** critical identifier fields may be blank
> **When** the data quality report is produced
> **Then** missing values are reported as both a count and a percentage of the total

*Verified: orders missing batch identifier 316 of 1,796 (17.6%); complaints missing batch identifier 46 of 100 (46%).*

**AC-13.2**
> **Given** a finding depends on a field with known gaps
> **When** that finding is presented
> **Then** it is explicitly described as a floor rather than a complete count

---

### US-14 — Keep invalid records rather than delete them

**AC-14.1**
> **Given** a record fails validation
> **When** the data is loaded
> **Then** the record is written to an exceptions table rather than discarded

*Verified: three exceptions tables covering batches, orders and recall risks.*

**AC-14.2**
> **Given** records have been quarantined
> **When** row counts are compared between source and destination
> **Then** every difference is accounted for by a documented exception

**AC-14.3**
> **Given** a quarantined parent record has dependent child records
> **When** the parent is quarantined
> **Then** the treatment of the children is an explicit, documented decision

*Verified: batch B-0041 quarantined; the four orders and one complaint referencing it had the batch link severed rather than the records removed, preserving sales history.*

---

### US-15 — Get the same answer every time

**AC-15.1**
> **Given** the same data and the same query
> **When** run by different people
> **Then** the results are identical

**AC-15.2**
> **Given** records must be excluded from an analysis
> **When** the exclusion is applied
> **Then** it is encoded in the query rather than applied manually

---

### US-16 — Prevent broken relationships between records

**AC-16.1**
> **Given** the database schema
> **When** it is created
> **Then** primary keys and foreign key relationships are enforced, along with constraints preventing impossible values

*Verified: foreign keys across all eight core tables; check constraints on date ordering and dispatch sequence.*

**AC-16.2**
> **Given** an orphan detection check
> **When** it returns no results
> **Then** the check itself is verified against a record known to be an orphan before the result is accepted

*A check that returns nothing is indistinguishable from a check that does not work. Verified using known orphan orders O-00101 and O-00201, which the control correctly returned.*

---

### US-17 — Understand what the analysis assumed

**AC-17.1**
> **Given** an assumption materially affects a result
> **When** the result is presented
> **Then** the assumption is stated together with the impact if it proves incorrect

*Verified: three assumptions documented in Report Section 8, each with its consequence.*

---

### US-19 — Compare figures across reports with confidence

**AC-19.1**
> **Given** a calculation depends on the current date
> **When** it is performed
> **Then** it references a fixed reporting date rather than the system date

**AC-19.2**
> **Given** the report and the dashboard present the same measure
> **When** both are produced
> **Then** the figures agree

*Verified: expired stock $9,961.49 and 13 batches expiring within 30 days agree exactly between SQL output and dashboard.*

**AC-19.3**
> **Given** the reporting date affects classification
> **When** the report is published
> **Then** the date is stated once, prominently

---

## Epic 6: Communication

### US-18 — Read findings without technical knowledge

**AC-18.1**
> **Given** the final report
> **When** it is read by a non technical stakeholder
> **Then** no SQL appears in the body, with queries referenced by file instead

**AC-18.2**
> **Given** a figure is presented
> **When** it appears in the report
> **Then** it is accompanied by what it means for the business

**AC-18.3**
> **Given** a reader wants the underlying detail
> **When** they look for it
> **Then** the supporting query file is identified

---

## Definition of done

A story is complete when:

1. All its acceptance criteria pass.
2. The supporting query or dashboard element is committed to the repository.
3. Findings are documented with their limitations stated.
4. Any assumption made is recorded in Report Section 8.
5. Figures reconcile between SQL output and dashboard.

Point 5 was added during the project rather than defined at the start. Early figures disagreed between the two because the dashboard counted all batches while the queries counted only batches holding stock. Both were internally consistent and told different stories, which is the failure mode this criterion now prevents.

---

## Note

FreshRoute Foods Ltd is a fictional company created for this case study. Verification results are drawn from the simulated dataset as at 31 July 2026.
