# Discovery Questions

**FreshRoute Foods Ltd — Batch and Recall Risk Analytics**

Prepared by: Vyom Patel
Date: 5 August 2026

---

## Purpose

These are the questions used to elicit requirements and understand the current state, grouped by stakeholder. They are recorded here as part of the analysis method rather than as a completed interview transcript.

Questions are written to be open rather than leading. "How long does a recall trace take?" invites a description of the process. "Does the recall trace take too long?" invites a yes. The first is useful; the second confirms what the analyst already assumed.

Where a question produced a finding in the analysis, that finding is noted.

---

## Grant (General Manager)

**Understanding the business driver**

1. What prompted this piece of work now, rather than six months ago?
2. What happened during the last recall, from the moment the notice arrived?
3. What would a poor outcome look like? What are you most concerned about?
4. Who else in the business is affected when a recall happens?
5. If you could have one number on a screen every morning, what would it be?

**Understanding constraints**

6. What can realistically change, and what is fixed?
7. Is there appetite for changing how data is captured, or only for reporting on what already exists?
8. What is the tolerance for slowing down day to day operations in exchange for better data?
9. Who has authority to approve a stock write off, and what is the current threshold?

**Understanding success**

10. Six months from now, how would you know this project had been worth doing?
11. Is speed of recall the priority, or confidence in its completeness?

> Question 11 turned out to matter more than expected. Speed is the visible problem, but completeness is the real one. A fast trace that misses customers is worse than a slow trace that finds them all.

---

## Dana (Operations Manager)

**Understanding the current process**

12. Walk me through what happens when a delivery arrives. Who records what, and where?
13. What checks are performed on batch information at the point of entry?
14. How do you currently know that stock is approaching expiry?
15. What triggers a write off? Who initiates it?
16. When stock is found past expiry, what happens to it?

**Understanding the pain**

17. Where in the current process do you lose the most time?
18. What do you find yourself doing manually that you feel should be automatic?
19. Which reports do you currently produce, and which do you actually use?
20. What do you not currently know that you wish you did?

**Understanding the data**

21. Which fields on an order are mandatory today, and which are left blank in practice?
22. When a batch reference is missing from an order, what do people do?
23. Are there known problems with the stock data that everyone works around?

> Questions 21 and 22 pointed directly at the central finding. 17.6% of orders carry no batch identifier, and the workaround is individual judgement, which is why traces cannot be reproduced.

---

## Priya (Quality Manager)

**Understanding recall response**

24. How does a supplier recall notice reach you, and what do you do first?
25. Where is that notice recorded? Who else sees it?
26. How do you decide whether a batch level concern warrants action?
27. Have there been occasions where a problem was visible before it became urgent?

**Understanding complaints**

28. How is a customer complaint logged, and what information is captured?
29. How often can a complaint be traced back to a specific batch?
30. What happens to a complaint that cannot be attributed to a product or batch?
31. How do you decide a complaint is resolved?

**Understanding supplier management**

32. How do you currently assess supplier quality? What evidence do you use?
33. Which supplier documents are required, and does that vary by supplier type?
34. How do you know when a supplier document is due to expire?
35. What would prompt a supplier review, and who makes that call?

> Question 27 produced the sharpest finding in the project. Complaint CMP-099 was open against the recall batch for three weeks before the supplier's notice arrived, with no process to escalate a single complaint into a batch level concern.
>
> Question 33 remains open. The analysis assumes all five document types are required for every supplier, and that assumption still needs confirming. It is recorded as a dependency on recommendation R7.

---

## Warehouse team

36. How do you locate a specific batch when you are asked to find one?
37. How often are physical stock counts performed, and what do they cover?
38. What do you do when the system quantity does not match what is on the shelf?
39. Would you rather be given a list of specific locations to check, or a full stock sweep?

---

## Sales team

40. When a recall happens, how do you know who to contact?
41. What contact information do you hold for each customer, and how current is it?
42. Who is the right person to reach at a customer during an urgent situation?
43. What happens when the contact on file has left the business?

> Question 41 anticipated a finding the recall trace confirmed. Addington Espresso Bar received affected stock and has no contact person recorded.

---

## Procurement

44. How are order quantities decided for each product line?
45. Does shelf life factor into order quantity, and if so how?
46. Which products do you order most frequently, and why?
47. Have you ever changed an order pattern because stock was expiring?

---

## Finance

48. How is expired stock currently written off, and on what cycle?
49. How confident are you that reported stock on hand reflects sellable stock?
50. What is the approval process for a write off, and does the value affect it?

---

## IT

51. Which systems hold batch, order and complaint data, and do they talk to each other?
52. Can validation rules be added at the point of entry, and what is involved?
53. Can a field be made mandatory without a major system change?
54. What reporting already exists, and who maintains it?

---

## Questions that remain open

Three questions were not fully answered and are carried into the analysis as documented assumptions:

| Question | Status | Impact |
|---|---|---|
| Q33: Are all five document types required for every supplier? | Open | If not, the 52% documentation gap overstates the problem. Dependency on R7. |
| Q26: Should recall risks marked "In progress" be treated as open? | Assumed yes | A stricter reading reduces the recall risk counts in the supplier analysis. |
| Q22: What should happen to orders with no batch reference? | Open | Determines whether the 316 unlinked orders are treated as unattributable or reconstructed. The analysis treats them as unattributable. |

Recording these openly matters more than resolving them. An assumption that is stated can be challenged; one that is buried silently in a query cannot.

---

## Note

FreshRoute Foods Ltd is a fictional company created for this case study. These questions represent the elicitation approach taken to the simulated scenario rather than a record of interviews conducted.
