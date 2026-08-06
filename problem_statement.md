# Problem Statement

**FreshRoute Foods Ltd — Batch and Recall Risk Analytics**

Prepared by: Vyom Patel
Date: 5 August 2026

---

## Background

FreshRoute Foods Ltd is a New Zealand FMCG distributor supplying chilled, ambient and frozen grocery products to cafés, dairies, supermarkets, foodstores and restaurants across six regions. The business sources from 14 suppliers, holds stock across two warehouse zones, and serves 70 trade customers.

As a food distributor, FreshRoute carries a legal and commercial obligation to trace any batch of product from the supplier who provided it to every customer who received it. That obligation becomes urgent when a supplier issues a recall notice.

## The problem

**FreshRoute cannot reliably or quickly determine which customers received a given batch of product.**

Batch, order, complaint and supplier information is held in separate spreadsheets with no dependable link between them. When a recall notice arrives, the affected customer list must be reconstructed by hand, cross referencing order history against stock records.

The most recent recall took **6.5 hours** to produce a customer contact list. During that time, affected product remained on sale at customer premises.

Speed is only part of the problem. Because a significant proportion of order records carry no batch reference, the person performing the trace must decide case by case whether an order should be included. The result depends on individual judgement, cannot be reproduced, and cannot be audited.

## Why it matters

**Regulatory.** Food distributors are expected to demonstrate traceability. A trace that relies on manual reconstruction and individual judgement is difficult to evidence to an auditor.

**Commercial.** Every hour between a recall notice and customer contact is an hour in which affected product may be sold or consumed. The reputational cost of a customer learning about a recall from someone other than FreshRoute is significant.

**Operational.** The same disconnected data prevents the business from seeing routine risks. Stock passes its expiry date unnoticed until a physical count finds it. Customer complaints cannot be attributed to the supplier responsible. Risk is assessed reactively rather than monitored.

**Financial.** Value is lost quietly. Stock expires on the shelf, and the loss is recognised only when someone happens to look.

## Scope of this project

**In scope**

- Cleaning and consolidating eight source datasets into a single relational database
- Documenting data quality issues and their impact on decision making
- SQL analysis covering expiry risk, stock value at risk, supplier quality and complaint patterns
- A Power BI dashboard for ongoing monitoring
- A worked recall traceability scenario against a live batch, measured against the manual baseline
- Recommendations for process improvement

**Out of scope**

- Changes to FreshRoute's operational source systems. This project analyses the data those systems produce; it does not modify them.
- Retrospective repair of historical records with missing batch identifiers. These are treated as permanently unattributable rather than reconstructed by inference.
- Financial forecasting, demand planning or supplier contract negotiation.
- Implementation of the recommendations, which requires decisions and resourcing outside this analysis.

## Success criteria

| # | Criterion | Measure |
|---|---|---|
| SC1 | A recall trace can be produced in minutes rather than hours | Time from batch identification to customer contact list |
| SC2 | The trace is reproducible | Two people running the same trace obtain the same result |
| SC3 | Recall exposure can be quantified | Value of stock dispatched and stock on hand, reported together |
| SC4 | Expiry risk is visible before value is lost | Stock value at risk reported by expiry window |
| SC5 | Data quality limitations are documented, not hidden | Every material gap quantified and stated in the final report |

SC5 is deliberate. An analysis that conceals the proportion of records it cannot see would produce confident numbers on an unreliable base, which is more dangerous than acknowledging the gap.

## Note on the data

The data used in this project is simulated. FreshRoute Foods Ltd is a fictional company created for this case study, and the dataset was generated to contain realistic data quality problems. The analysis, methods and findings are genuine; the company is not.
