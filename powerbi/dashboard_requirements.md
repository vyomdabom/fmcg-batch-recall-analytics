# Power BI Dashboard Requirements

> Requirements only — visual choices, layout, DAX, and the data model are yours. Wireframe each page before building. Global: consistent slicers (product, supplier, customer type, region, expiry window, risk level), a data-refresh date stamp, and sensible handling of records with missing batch IDs (surface them — don't hide them).

## Page 1 — Executive Overview

- **Purpose:** One-glance health check of batch, expiry, supplier, and complaint risk.
- **User:** Grant Hollis (GM), Dana (Ops Manager).
- **Decisions supported:** Where to focus this week; whether risk is trending up; whether to trigger a deeper review.
- **Content:** KPI cards — total active batches, total products, total suppliers, total customers, high-risk batch count, stock value at risk, batches expiring ≤30 days, total complaints (period). Plus one trend visual (your choice) and a top-risk callout.

## Page 2 — Expiry & Batch Risk

- **Purpose:** Operational management of expiry risk and write-off prevention.
- **User:** Dana, Tom (Warehouse Lead).
- **Decisions supported:** Which stock to move/discount/dispose first; FEFO pick priorities; write-down provisioning.
- **Content:** Batches by expiry window (30/60/90), quantity remaining by batch, stock value at risk by window and product, products closest to expiry, warehouse location of risky stock. Include batches with missing expiry dates as an explicit "unknown" category.

## Page 3 — Supplier Quality

- **Purpose:** Evidence base for supplier reviews and document compliance.
- **User:** Priya (Quality), Grant for supplier decisions.
- **Decisions supported:** Which suppliers to review, renegotiate, or exit; which documents to chase this week.
- **Content:** Complaints by supplier, missing/expired documents by supplier, failed quality checks, supplier issue rate (issues per batch supplied — fairer than raw counts), supplier quality score (design and document your scoring method).

## Page 4 — Recall Traceability

- **Purpose:** Answer "batch X is suspect — who got it and what's our exposure?" in minutes.
- **User:** Priya and Dana during an incident; Mel for the contact list; Grant for exposure.
- **Decisions supported:** Recall go/no-go, customer contact priority, stock hold instructions.
- **Content:** Batch selector (slicer) → product and supplier linked to the batch, customers who received it (table: customer, region, dispatch date, quantity), regions affected (map or bar), quantity sold vs remaining, recall exposure value, linked complaints. Test against batch YD-2408-A.

## Page 5 — Customer Complaints

- **Purpose:** Complaint patterns, root-cause signals, and service performance.
- **User:** Mel (Sales/Support), Priya.
- **Decisions supported:** Which products/suppliers to investigate; complaint handling resourcing; SLA management.
- **Content:** Complaints by product, by customer type, by severity; complaint trend over time; average resolution time; open complaints list; % complaints without a batch ID (make the traceability gap visible).

## Acceptance (tie back to user stories)

Each page should satisfy the relevant acceptance criteria in `ba-documents/07_acceptance_criteria.md`. Screenshot every finished page into `powerbi/screenshots/` for the README.
