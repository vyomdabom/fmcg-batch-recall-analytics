# Recommendations

**FreshRoute Foods Ltd — Batch and Recall Risk Analytics**

Prepared by: Vyom Patel
Report date: 5 August 2026
All supporting figures as at 31 July 2026

This document sets out the full recommendations arising from the analysis. The three highest priority items are summarised in Section 7 of the Final Insights Report. Each recommendation below states the problem, the evidence behind it, the proposed action, the expected benefit, and an indicative effort and owner.

Impact and effort are rated High, Medium or Low. Effort is a relative estimate only and should be confirmed with the teams involved.

---

## Priority summary

| # | Recommendation | Impact | Effort | Owner |
|---|---|---|---|---|
| R1 | Make batch identifier mandatory at order entry and complaint logging | High | Low | Operations / IT |
| R2 | Log external supplier notifications into the recall risk register on receipt | High | Low | Quality |
| R3 | Add date validation at goods in | Medium | Low | Operations / IT |
| R4 | Introduce a date driven write off process | Medium | Medium | Operations / Finance |
| R5 | Targeted rotation review for three chilled product lines | Medium | Low | Procurement / Operations |
| R6 | Complete missing customer contact records | Medium | Low | Sales |
| R7 | Track supplier document currency and chase before expiry | Medium | Medium | Quality / Procurement |
| R8 | Formally adopt and recalibrate the batch risk scoring model | Medium | Medium | Quality |

---

## R1. Make batch identifier mandatory at order entry and complaint logging

**Problem.** FreshRoute cannot reliably connect a batch to the customers who received it, or a customer complaint back to the batch that caused it.

**Evidence.** 316 of 1,796 orders (17.6%) have no batch identifier. 46 of 100 complaints (46%) have no batch identifier, and a further 5 have no product identifier. This is the direct cause of the 6.5 hours the last recall trace took, and the reason supplier quality reporting understates issues by up to half.

**Recommendation.** Make the batch identifier a required field at the point of capture, both when an order is entered and when a complaint is logged. Where an operator genuinely cannot supply it, require an explicit reason code rather than allowing a silent blank, so the gap is measurable rather than invisible.

**Benefit.** Every downstream measure improves at once. Recall traces become complete rather than partial, complaints become attributable to suppliers, and the risk model gains the input it currently lacks. This is the single highest value change in this document.

**Effort.** Low. A validation rule at the point of entry, not a system replacement.

**Note on scope.** This closes the gap going forward. It does not repair the 316 historical orders, which should be treated as permanently unattributable rather than retrospectively guessed. Do not backfill by inference; an incorrect batch link is worse than an acknowledged blank.

**Owner.** Operations, with IT for the system change.

---

## R2. Log external supplier notifications into the recall risk register on receipt

**Problem.** The internal risk model cannot see risks that originate outside the business.

**Evidence.** Batch B-0187, the subject of the live recall, scored only 3 out of a possible 12 under the risk scoring in query C12 and did not appear among the ten highest risk batches. It scored low because the supplier's notification existed only as correspondence and had never been entered into the recall risk register. Separately, complaint CMP-099 had been open against that same batch since 6 July 2026, three weeks before the recall notice arrived, with no process to escalate a single complaint into a batch level concern.

**Recommendation.** Require that any supplier quality notification, recall notice or product advisory is recorded against the affected batch in the recall risk register within 24 hours of receipt. Add a secondary trigger so that an open complaint against a batch raises that batch's risk profile rather than sitting in isolation.

**Benefit.** The batch would have been flagged before the formal recall arrived, giving FreshRoute a head start on customer contact and stock hold. A risk model that cannot see incoming notifications will always miss them, however well its weights are set.

**Effort.** Low. A process step and a discipline, not a system build.

**Owner.** Quality.

---

## R3. Add date validation at goods in

**Problem.** Impossible dates are being accepted at the point of receipt.

**Evidence.** Four batches carry manufacture dates in the future as at 31 July 2026, spread across four different suppliers. A further three batches were future dated when first checked on 17 July but no longer appear as such, because the passage of time hides the error. Because the affected batches span multiple suppliers rather than clustering with one, the cause is FreshRoute's own receiving process rather than any supplier's paperwork.

**Recommendation.** Add validation at goods in that rejects a manufacture date later than today, rejects a manufacture date later than the expiry date, and requires an expiry date to be present before the record can be saved.

**Benefit.** Prevents recurrence at source. The point about time hiding these errors matters: periodic checks will always understate the problem, because a future date recorded today looks correct next month. Validation at entry is the only reliable control.

**Effort.** Low.

**Owner.** Operations, with IT for the validation rule.

---

## R4. Introduce a date driven write off process

**Problem.** Expired stock remains on the books until someone physically finds it.

**Evidence.** 21 batches have passed their expiry date while still showing units on hand, representing $9,961.49 of unrecognised loss. Several are substantially overdue, including IC-2512-A at 156 days past expiry and C3-2601-A at 154 days. Stock sitting five months past expiry indicates write off is triggered by stock counts rather than by date.

**Recommendation.** Run a scheduled review, weekly or fortnightly, that lists all batches past expiry with stock remaining and routes them for disposal or write off. Pair it with a forward looking report covering the next 30 days so action can be taken before value is lost rather than after.

**Benefit.** Recognises $9,961.49 of existing loss and prevents its recurrence. It also improves the accuracy of stock on hand, which currently overstates sellable inventory.

**Effort.** Medium. Requires a recurring process and an agreed write off authority, not just a report.

**Owner.** Operations, with Finance for the write off approval.

---

## R5. Targeted rotation review for three chilled product lines

**Problem.** Near expiry exposure is concentrated in a small number of products, but is being managed as though it were spread evenly.

**Evidence.** Total near expiry exposure is $37,963.28 across 60 batches. The ten highest value products account for $33,437.68 of that, or 88%. Cream 300ml ($7,864.04) and Iced Coffee 350ml ($6,449.96) alone carry $14,314, roughly 38% of the total. Adding Custard 600g brings three products to close to half of all exposure. Both Cream 300ml and Iced Coffee 350ml also appear repeatedly among the ten batches furthest past expiry, so two independent views of the data point to the same lines. Chilled stock overall represents 83% of near expiry value.

**Recommendation.** Review order quantities, order frequency and stock rotation for Cream 300ml, Iced Coffee 350ml and Custard 600g specifically. Establish whether the cause is over ordering, slow rotation, or a mismatch between order cycle and shelf life.

**Benefit.** Addresses close to half of total exposure without a warehouse wide programme. This is the highest return per unit of effort in this document.

**Effort.** Low. Three product lines, not a full range review.

**Owner.** Procurement, with Operations on rotation practice.

---

## R6. Complete missing customer contact records

**Problem.** Some customers cannot be contacted during a recall.

**Evidence.** Addington Espresso Bar (C-016) received units of recall batch YD-2408-A but has no contact person recorded. This was discovered only because the recall trace surfaced it.

**Recommendation.** Audit the customer table for missing contact names, phone numbers and email addresses, and complete them. Make a contact person mandatory on customer creation thereafter.

**Benefit.** A recall is exactly the moment when incomplete contact data becomes expensive. A customer who cannot be reached is a customer who continues selling affected product.

**Effort.** Low, and it can be done independently of any system change.

**Owner.** Sales.

---

## R7. Track supplier document currency and chase before expiry

**Problem.** Supplier documentation is incomplete and expiring without being noticed.

**Evidence.** 38 supplier documents have expired. 156 of 298 batches (52%) originate from suppliers missing at least one required document type, arising from eight supplier and document type gaps. Southern Fine Foods holds five expired documents, with Alpine Provisions, Pacific Beverage Co and Waikato Dairy Collective at four each.

**Recommendation.** Maintain a document register with expiry dates and a standing report of documents expiring within 60 days, so renewals are chased before they lapse rather than discovered afterwards.

**Benefit.** Reduces audit exposure. Over half of current stock traces to a supplier whose paperwork is not current, which is a compliance risk as much as a quality one.

**Dependency.** This analysis assumes all five document types are required for every supplier. Quality should confirm that assumption first, because if some document types apply only to certain supplier categories, the 52% figure overstates the problem and the priority may drop.

**Effort.** Medium.

**Owner.** Quality, with Procurement for supplier follow up.

---

## R8. Formally adopt and recalibrate the batch risk scoring model

**Problem.** Risk is currently assessed informally, and the one model tested failed on a live case.

**Evidence.** The scoring model in query C12 weights an open recall risk at 5 points, expired stock at 4, a document problem at 2 and an existing complaint at 1. Applied to the live recall batch B-0187, it returned a score of 3 and did not rank in the top ten. The weights themselves were reasonable; the failure was an input gap, addressed by R2.

**Recommendation.** Adopt the scoring model as a standing report once R2 is in place, then review the weights with Quality after a period of operation. Consider whether an open complaint should carry more than 1 point, given that CMP-099 was a genuine early signal that the current weighting treats as minor.

**Benefit.** Turns risk assessment into something repeatable and reviewable rather than a judgement call. The weights are a business decision and should be owned by Quality rather than embedded silently in a query.

**Dependency.** Do not implement before R2. Recalibrating a model that cannot see external notifications would optimise the wrong thing.

**Effort.** Medium.

**Owner.** Quality.

---

## Not recommended: changing supplier over the recall

It is worth stating explicitly what the evidence does not support.

Meadow Valley Dairy Ltd supplied the recall batch, and the instinct after a recall is to question the supplier relationship. The data does not support that here. Meadow Valley supplies more batches than any other supplier at 53, has recorded zero failed QC batches, carries the lowest issue rate in the portfolio at 0.11, and holds the highest quality score at 91.32.

On the available evidence this is a single batch event at an otherwise strong supplier, not the symptom of a deteriorating relationship. The appropriate response is process improvement, specifically R1 and R2, rather than supplier replacement.

Where supplier attention is warranted, the evidence points elsewhere: Kereru Organics on complaint rate (0.32 per batch, the highest in the portfolio), Golden Coast Trading on quality control (a failed QC rate of 0.27, though across a small base of 11 batches), and Waikato Dairy Collective and Southern Fine Foods on documentation and overall score.

---

## Suggested sequencing

**Immediate (0 to 30 days).** R1, R2, R6. All are low effort, and R1 and R2 together address the root cause of the recall delay. R6 can proceed in parallel with no dependencies.

**Short term (1 to 3 months).** R3, R5. R3 prevents recurrence of a data quality problem at source. R5 delivers the largest financial return relative to effort.

**Medium term (3 to 6 months).** R4, R7, R8. Each requires an agreed process and an owner rather than a single change, and R8 depends on R2 being in place first.

---

## Caveat

These recommendations rest on a dataset in which 17.6% of orders and 46% of complaints carry no batch identifier. Every count that depends on batch linkage should be read as a floor rather than a full tally. This does not change the direction of any recommendation, but it does mean the underlying problems are likely larger than the figures suggest, which strengthens rather than weakens the case for R1.

The data used in this analysis is simulated. FreshRoute Foods Ltd is a fictional company created for this case study, and none of the supplier findings should be read as commentary on any real organisation.
