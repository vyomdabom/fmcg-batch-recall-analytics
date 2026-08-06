# User Stories

**FreshRoute Foods Ltd — Batch and Recall Risk Analytics**

Prepared by: Vyom Patel
Report date: 5 August 2026

Twenty-one stories grouped into six epics. Each one states who needs the capability, what
they need, and why it matters to them — the "so that" is the part that carries the business
case, so none of them is left implicit.

Every story maps to a business requirement in `03_business_requirements.md` and is made
testable by the Given/When/Then criteria in `05_acceptance_criteria.md`. Those three
documents are meant to be read together: the requirement says what the solution must do,
the story says who wants it and why, and the criteria say how you would know it works.

---

## Epic 1: Recall traceability

### US-01 — Trace a batch to its customers

**As** the Quality and Compliance Coordinator
**I want** to enter a batch number and get back every customer who received stock from it, with quantities, dispatch dates, regions and contact details
**So that** I can begin contacting affected customers within minutes of a recall notice instead of spending most of a working day reconstructing the answer from spreadsheets.

*Requirement: BR-01. Criteria: AC-01.1 to AC-01.5.*

### US-02 — Understand the financial exposure of a recall

**As** the General Manager
**I want** to see the value of stock already dispatched and the value still held, both separately and combined
**So that** I can size the commercial impact of a recall before deciding how far to escalate it.

*Requirement: BR-02. Criteria: AC-02.1 to AC-02.3.*

### US-03 — See existing complaints against a recalled batch

**As** the Quality and Compliance Coordinator
**I want** any complaint already logged against a batch to surface as part of the trace
**So that** an early warning we already hold is not discovered after the recall has been announced.

*Requirement: BR-03. Criteria: AC-03.1 to AC-03.3.*

### US-06b — Know which affected customers cannot be contacted

**As** a member of the Sales team
**I want** affected customers with incomplete contact details flagged explicitly
**So that** I find out during the trace rather than when a call fails, and can chase the details while the rest of the contact list is being worked through.

*Criteria: AC-06b.1. This story emerged from the live recall test, where an affected customer was found to have no contact person recorded.*

### US-20 — Select any batch without technical help

**As** the Operations Manager
**I want** to run the trace for any batch myself, by choosing it from a list
**So that** recall response does not depend on someone who can write a query being available.

*Requirement: BR-20. Criteria: AC-20.1 to AC-20.2.*

---

## Epic 2: Expiry and stock risk

### US-04 — See stock approaching expiry

**As** the Operations Manager
**I want** stock grouped by how close it is to expiry, with the value attached to each window
**So that** I can act on short dated stock while it still has commercial value rather than writing it off later.

*Requirement: BR-04. Criteria: AC-04.1 to AC-04.5.*

### US-05 — Identify stock already past expiry

**As** the Operations Manager
**I want** a list of batches that have passed their expiry date but still show units on hand
**So that** loss we have already incurred is recognised and the stock is removed from sale, instead of sitting on the books until someone physically finds it.

*Requirement: BR-05. Criteria: AC-05.1 to AC-05.2.*

### US-11 — Know which products drive expiry risk

**As** the Operations Manager
**I want** expiry exposure broken down by product and storage type
**So that** I can target the few lines causing most of the problem instead of running a review across the whole range.

*Requirement: BR-11. Criteria: AC-11.1 to AC-11.3.*

### US-12 — Target a physical stock review

**As** the Warehouse Lead
**I want** at-risk stock reported by warehouse location
**So that** a stock check can cover the highest exposure in a couple of aisles rather than walking the whole warehouse.

*Requirement: BR-12. Criteria: AC-12.1.*

---

## Epic 3: Supplier quality

### US-06 — Rank suppliers by quality issues

**As** the Quality and Compliance Coordinator
**I want** suppliers ranked using quality control failures, complaints and open recall risks together, as a rate rather than a raw count
**So that** supplier reviews are based on evidence rather than impression, and a large supplier is not penalised simply for supplying more.

*Requirement: BR-06. Criteria: AC-06.1 to AC-06.4.*

### US-07 — See which batches came from under documented suppliers

**As** the Quality and Compliance Coordinator
**I want** to know which stock on hand traces back to a supplier with missing or expired documentation
**So that** I can chase the paperwork before an audit finds it, and know what is exposed in the meantime.

*Requirement: BR-07. Criteria: AC-07.1 to AC-07.3.*

### US-09 — See which batches are highest risk

**As** the Quality and Compliance Coordinator
**I want** batches scored on a consistent combination of risk signals
**So that** attention goes to the batches that warrant it, using a rule that can be reviewed and challenged rather than a judgement made afresh each time.

*Requirement: BR-09. Criteria: AC-09.1 to AC-09.4.*

---

## Epic 4: Complaints

### US-08 — Compare complaint rates fairly across products

**As** the Quality and Compliance Coordinator
**I want** complaints expressed per thousand units sold alongside the raw count
**So that** a high volume product is not mistaken for a problem product, and a genuinely faulty low volume line is not overlooked.

*Requirement: BR-08. Criteria: AC-08.1 to AC-08.4.*

### US-10 — Understand complaint resolution performance

**As** the Operations Manager
**I want** resolution times reported by severity and complaint type
**So that** I can see whether serious complaints are actually being handled faster than minor ones.

*Requirement: BR-10. Criteria: AC-10.1 to AC-10.3.*

---

## Epic 5: Data quality and trust

### US-13 — Know how much of the data can be trusted

**As** the General Manager
**I want** every report to state how complete the data behind it is
**So that** I know whether a figure is the full picture or a floor, and can weigh a decision accordingly.

*Requirement: BR-13. Criteria: AC-13.1 to AC-13.2.*

### US-14 — Keep invalid records rather than delete them

**As** the Quality and Compliance Coordinator
**I want** records that fail validation to be quarantined with a stated reason instead of discarded
**So that** nothing is lost silently, every exclusion can be explained to an auditor, and any decision can be reversed.

*Requirement: BR-14. Criteria: AC-14.1 to AC-14.3.*

### US-15 — Get the same answer every time

**As** the Operations Manager
**I want** the same question to return the same answer regardless of who runs it
**So that** figures can be relied on in a recall, when there is no time to reconcile two versions of the truth.

*Requirement: BR-15. Criteria: AC-15.1 to AC-15.2.*

### US-16 — Prevent broken relationships between records

**As** the Operations Manager
**I want** the system to reject records that reference something that does not exist
**So that** the links traceability depends on cannot quietly break the way they did across our spreadsheets.

*Requirement: BR-16. Criteria: AC-16.1 to AC-16.2.*

### US-17 — Understand what the analysis assumed

**As** the General Manager
**I want** the assumptions behind each figure recorded alongside it
**So that** I can tell the difference between a finding and an artefact of how something was counted.

*Requirement: BR-17. Criteria: AC-17.1.*

### US-19 — Compare figures across reports with confidence

**As** the General Manager
**I want** every report to state the date its figures are current to
**So that** two reports can be compared without wondering whether they were run on the same day.

*Requirement: BR-19. Criteria: AC-19.1 to AC-19.3.*

---

## Epic 6: Communication

### US-18 — Read findings without technical knowledge

**As** the General Manager
**I want** findings written in business language, with the technical work referenced rather than reproduced
**So that** I can act on the analysis without having to interpret it.

*Requirement: BR-18. Criteria: AC-18.1 to AC-18.3.*

---

## How these stories were checked

Each story was tested against the INVEST standard before being accepted:

| Test | How it was applied here |
|---|---|
| Independent | No story depends on another being delivered first. US-06b refines US-01 but stands on its own. |
| Negotiable | Each states the need, not the implementation. How the trace is built is a design decision. |
| Valuable | Every story names a benefit to a specific role, not to "the business" in general. |
| Estimable | Scope is bounded enough that effort could be judged; none is open ended. |
| Small | Where a story grew too broad it was split. Expiry risk became four stories rather than one. |
| Testable | Every story has at least one Given/When/Then criterion in `05_acceptance_criteria.md`. |

Twenty of the twenty-one stories trace to a numbered business requirement. US-06b is the
exception: it came out of the live recall test rather than the requirements workshop, and
is recorded here as a refinement of US-01 rather than being retrofitted into the
requirements to make the numbering tidy.
