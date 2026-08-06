# Mock Recall Test Scenario — Batch YD-2408-A

> This is your end-to-end test. Do not read further guidance into it — investigate it with your data, SQL, and dashboard exactly as you would at work. Write up the outcome in `report/final_insights_report.md`.

## The notification

**From:** Quality Manager, Meadow Valley Dairy Ltd
**To:** Priya Sharma, FreshRoute Foods
**Subject:** URGENT — Potential temperature excursion, Batch YD-2408-A

Priya,

During a routine review of our cold-chain logger data we identified that pallets containing **Batch YD-2408-A of Yoghurt Drink 250ml** may have been exposed to temperatures above 6°C for up to five hours during transit to your Auckland warehouse. Product safety testing is underway; results expected within 48 hours. As a precaution we recommend you place remaining stock on hold and prepare for a possible withdrawal of product already distributed.

We will confirm by end of week.

## Your investigation task

Dana wants a briefing within 2 hours (simulate this time pressure — note how long it actually takes you). Using your cleaned data, SQL, and dashboard, determine:

1. How much stock of YD-2408-A remains in the warehouse, and where
2. How much has been sold, over what date range
3. Which customers received the batch (full contact list with quantities and dispatch dates)
4. Which regions are affected
5. Whether any existing complaints are linked to this batch (or to this product around the relevant dates — remember ~30% of complaints have no batch ID)
6. The total recall exposure value
7. Whether Meadow Valley Dairy has previous quality issues, document gaps, or recall-risk history

## Deliverable

A one-page briefing note for Dana: situation, findings (numbered above), recommended immediate actions, and any data gaps that limited your trace (e.g. orders with missing batch IDs that *might* contain this batch — how do you handle those honestly?).

## Data setup reminder

When you generate your dataset, ensure YD-2408-A exists with: remaining warehouse stock, 10–20 orders across several regions and customer types, at least one plausibly-related complaint, and a supplier (Meadow Valley Dairy) with at least one prior issue and one document problem. Some orders of Yoghurt Drink 250ml in the same period should have blank batch IDs — that ambiguity is the point.
