# Project Brief — Batch Tracking & Recall Risk Review

> **Simulated portfolio project.** This brief is written in the style of a real internal assignment so the project feels like genuine workplace experience. FreshRoute Foods Ltd is fictional.

---

**To:** Graduate Business Analyst / Data Analyst
**From:** Dana Whitford, Operations Manager
**CC:** Grant Hollis (General Manager), Priya Sharma (Quality & Compliance Coordinator)
**Date:** (set a date roughly 2 weeks before you start the project)
**Subject:** Review of batch tracking, expiry management, and recall readiness

Welcome to the team. I need your help with something that's been keeping me up at night.

## What happened

Three weeks ago, a cafe in Hamilton complained that a 250ml chilled yoghurt drink tasted "off". Priya asked which batch it came from. The cafe didn't know, and neither did we — not quickly, anyway. The batch number was in the warehouse receiving spreadsheet, the order history was in a different workbook maintained by sales, the supplier's temperature records were somewhere in Priya's email, and two of the orders that week had no batch recorded at all. It took the team about six and a half hours to work out which customers had received stock from that batch. If that had been a genuine food safety recall, six and a half hours is not acceptable — MPI would expect us to trace affected product in a fraction of that time.

The product turned out to be fine (the cafe's fridge was the problem), but the exercise scared us. We got lucky.

## What I'm asking you to do

I want you to treat this as a proper analysis project:

1. **Understand the current process.** Talk to the warehouse team, sales, Priya, and me. Document how stock, batches, expiry dates, documents, orders, and complaints actually flow through the business today.
2. **Get the data into shape.** Pull together the spreadsheets we use (products, suppliers, batches, customers, orders, complaints, supplier documents, recall risk log). Fair warning: they're messy — different people maintain them, and nobody has ever reconciled them.
3. **Analyse the risk.** Show me what's expiring, what's missing documents, which suppliers keep causing issues, and how exposed we'd be in a recall.
4. **Build a dashboard.** Management needs to see this at a glance, not dig through spreadsheets.
5. **Recommend improvements.** Practical ones. We're an SME — we're not buying SAP next quarter.

There's also a live test for you: one of our suppliers has just flagged a possible temperature excursion on a yoghurt drink batch (details in `mock_recall_scenario.md`). Use it to prove your traceability analysis works.

## Your role

You're joining as a Graduate Business Analyst / Data Analyst reporting to me. You're expected to run stakeholder discovery, document processes and requirements, design and clean the data, write the SQL analysis, build the Power BI report, and present recommendations. Ask questions early — nobody expects you to know FMCG on day one.

## Expected outcome

By the end of the project I want: a documented current and future state, a cleaned and linked dataset, a working dashboard covering expiry risk, supplier quality, complaints, and recall traceability, and a short recommendations report I can take to Grant.

— Dana

---

## Project overview (portfolio framing)

| Item | Detail |
|---|---|
| Company | FreshRoute Foods Ltd — fictional Auckland-based FMCG distributor (~35 staff, ~450 SKUs, chilled/frozen/ambient) |
| Why the project exists | Growth has outpaced Excel-and-email processes; a near-miss complaint exposed the recall-readiness gap |
| Business problem | No centralised, reliable link between batches, expiry dates, supplier documents, orders, complaints, and recall exposure |
| Your role | Graduate BA/DA: discovery, process analysis, data design/cleaning, SQL, Power BI, requirements, recommendations |
| Expected outcome | Documented processes, cleaned linked dataset, 5-page dashboard, BA document pack, recommendations report |
| Skills demonstrated | Elicitation, process mapping, data modelling, data cleaning, SQL, dashboarding, requirements engineering, business communication |

## Business problem indicators

Each observed symptom points to an underlying business or data problem:

| # | Indicator | What it suggests |
|---|---|---|
| 1 | Batch data, orders, complaints, and documents live in at least 6 separate Excel files owned by different people | No single source of truth; joins between entities only exist in people's heads |
| 2 | Batch numbers are typed manually at goods-in | Typos, inconsistent formats, and blanks make traceability unreliable |
| 3 | Expiry dates are checked by eye when someone remembers | Expired or near-expiry stock can be dispatched; write-offs discovered too late |
| 4 | Supplier certificates (audits, HACCP, insurance) sit in email inboxes and ad-hoc folders | Expired/missing documents go unnoticed; compliance exposure with MPI and retail customers |
| 5 | Complaints are logged without batch numbers in ~a third of cases | Complaints can't be traced to root cause; supplier accountability is impossible |
| 6 | The yoghurt-drink trace took ~6.5 hours | Recall response far exceeds acceptable timeframes; process fails exactly when it matters most |
| 7 | Management gets updates by email and verbal summaries; no dashboard exists | Decisions on risk, stock, and suppliers are made on stale or partial information |
| 8 | Sales and warehouse keep separate copies of the order log that don't reconcile | Version conflict; nobody trusts the numbers; duplicated effort maintaining both |
| 9 | Stocktake found chilled product within 2 weeks of expiry that nobody had flagged | Financial loss from write-offs; risk of short-dated stock reaching customers |
| 10 | Two suppliers' audit certificates were found to have expired months ago | Supplier onboarding/review is not systematic; quality risk enters unchecked |

Your discovery interviews (see `ba-documents/03_discovery_questions.md`) should confirm, refine, and extend this list.
