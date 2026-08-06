"""
Generate freshroute_raw_data.xlsx — deliberately MESSY simulated company data
for the FMCG Batch & Recall Risk Analytics case study.

Reproducible: random seed fixed. See data_dictionary.md for the spec and the
list of deliberate data quality issues baked in.

Usage: python generate_raw_data.py  (writes raw/freshroute_raw_data.xlsx)
"""
import random
from datetime import date, timedelta

import pandas as pd

random.seed(42)
TODAY = date(2026, 7, 11)


# ---------- helpers ----------------------------------------------------------
def rdate(start: date, end: date) -> date:
    return start + timedelta(days=random.randint(0, (end - start).days))


def messy_date(d, blank_prob=0.0):
    """Return the date in a randomly chosen format (the mess is the point)."""
    if d is None or random.random() < blank_prob:
        return None
    r = random.random()
    if r < 0.55:
        return d.isoformat()                      # 2026-05-02
    if r < 0.80:
        return d.strftime("%d/%m/%Y")             # 02/05/2026
    if r < 0.92:
        return d.strftime("%-d-%b-%y")            # 2-May-26
    return d                                       # real date cell


REGIONS = ["Auckland", "Waikato", "Bay of Plenty", "Wellington", "Canterbury", "Otago"]
REGION_MESS = {"Auckland": ["Auckland", "Auckland", "Akl", "AKL", "Auckland "],
               "Wellington": ["Wellington", "Wellington", "Wgtn", "wellington"],
               "Waikato": ["Waikato", "Waikato", "waikato"],
               "Bay of Plenty": ["Bay of Plenty", "BOP", "Bay Of Plenty"],
               "Canterbury": ["Canterbury", "Canterbury", "Chch"],
               "Otago": ["Otago", "Otago", "otago"]}


def messy_region(region):
    return random.choice(REGION_MESS[region])


# ---------- 1. Products (52 rows incl. 1 duplicate) --------------------------
CATS = {"Dairy": ("Chilled", 1.2, 4.5), "Chilled Drinks": ("Chilled", 1.0, 4.0),
        "Protein Bars": ("Ambient", 1.5, 4.2), "Frozen Meals": ("Frozen", 3.0, 9.5),
        "Snacks": ("Ambient", 0.8, 3.5), "Sauces": ("Ambient", 1.1, 4.8),
        "Packaged": ("Ambient", 1.3, 5.0), "Health": ("Ambient", 2.0, 7.5)}
BRANDS = ["KiwiFresh", "Meadow Valley", "SouthPeak", "GoodGrain", "PureNZ",
          "Harbour Foods", "Alpine Co", "SunBasket"]
NAMES = {
    "Dairy": ["Yoghurt Drink 250ml", "Greek Yoghurt 500g", "Butter 500g", "Cheese Slices 250g",
              "Milk 2L", "Cream 300ml", "Custard 600g"],
    "Chilled Drinks": ["Orange Juice 1L", "Kombucha 330ml", "Iced Coffee 350ml",
                       "Smoothie Berry 300ml", "Sparkling Lemonade 750ml", "Oat Milk 1L"],
    "Protein Bars": ["Protein Bar Choc 60g", "Protein Bar Peanut 60g", "Protein Bites 120g",
                     "Muesli Bar 6pk", "Nut Bar Almond 45g", "Energy Bar Cacao 50g"],
    "Frozen Meals": ["Butter Chicken 400g", "Lasagne 400g", "Veg Curry 350g", "Fish Pie 450g",
                     "Dumplings 500g", "Pad Thai 400g"],
    "Snacks": ["Snack Box Kids", "Corn Chips 150g", "Rice Crackers 100g", "Trail Mix 200g",
               "Popcorn Sea Salt 80g", "Veggie Chips 90g", "Pretzels 120g"],
    "Sauces": ["Tomato Sauce 500ml", "Sweet Chilli 300ml", "Aioli 250ml", "BBQ Sauce 500ml",
               "Pasta Sauce 400g", "Soy Sauce 250ml"],
    "Packaged": ["Pasta Penne 500g", "Basmati Rice 1kg", "Chickpeas Can 400g", "Oats 750g",
                 "Crackers Water 125g", "Soup Pumpkin 400g", "Noodles 5pk"],
    "Health": ["Protein Powder 1kg", "Chia Seeds 300g", "Almond Butter 250g",
               "Granola 450g", "Kombucha Starter Kit", "Collagen Powder 200g"],
}

products = []
pid = 0
for cat, names in NAMES.items():
    storage, cmin, cmax = CATS[cat]
    for name in names:
        pid += 1
        cost = round(random.uniform(cmin, cmax), 2)
        products.append({
            "product_id": f"P-{pid:03d}", "product_name": name,
            "product_category": cat, "brand": random.choice(BRANDS),
            "storage_type": storage, "unit_cost": cost,
            "unit_sell_price": round(cost * random.uniform(1.45, 1.95), 2),
            "active_status": "Active"})

# fixed anchor: Yoghurt Drink 250ml must exist for the recall scenario
YOG = next(p for p in products if p["product_name"] == "Yoghurt Drink 250ml")
YOG["brand"] = "Meadow Valley"

# deliberate mess
for p in random.sample(products, 5):
    p["active_status"] = "Discontinued"
for p in random.sample(products, 3):
    p["active_status"] = ""                                   # blanks
for p in random.sample(products, 3):
    p["brand"] = ""
mess = random.sample([p for p in products if p["active_status"] != "Discontinued"], 6)
mess[0]["storage_type"] = "chilled" if mess[0]["storage_type"] == "Chilled" else mess[0]["storage_type"].lower()
mess[1]["storage_type"] = mess[1]["storage_type"].upper()
mess[2]["storage_type"] = "Fridge" if mess[2]["storage_type"] == "Chilled" else mess[2]["storage_type"]
mess[3]["unit_cost"] = f"${mess[3]['unit_cost']}"             # cost as text
mess[4]["unit_sell_price"] = round(float(str(mess[4]["unit_cost"]).lstrip("$")) * 0.8, 2)  # sells below cost
mess[5]["product_category"] = mess[5]["product_category"].rstrip("s") if mess[5]["product_category"] == "Snacks" else mess[5]["product_category"].lower()
# duplicate product with ID variant + spelling variant
products.append({**YOG, "product_id": "P-014B", "product_name": "Yogurt Drink 250 ml"}) if YOG["product_id"] == "P-014" else \
    products.append({**YOG, "product_id": YOG["product_id"] + "B", "product_name": "Yogurt Drink 250 ml"})

df_products = pd.DataFrame(products)

# ---------- 2. Suppliers (15 rows incl. 1 duplicate-entity) ------------------
SUPPLIER_NAMES = ["Meadow Valley Dairy Ltd", "Southern Fine Foods", "Pacific Beverage Co",
                  "Auckland Frozen Foods", "GrainWorks NZ", "Sunrise Snacks Ltd",
                  "Harvest Sauce Company", "NutriLife Health Foods", "Bay Packaging Foods",
                  "Kereru Organics", "TransTasman Imports", "Waikato Dairy Collective",
                  "Golden Coast Trading", "Alpine Provisions"]
suppliers = []
for i, name in enumerate(SUPPLIER_NAMES, 1):
    audit = rdate(date(2023, 11, 1), date(2026, 5, 1))
    suppliers.append({
        "supplier_id": f"S-{i:02d}", "supplier_name": name,
        "country": random.choice(["New Zealand", "New Zealand", "New Zealand", "Australia"]),
        "supplier_rating": random.randint(2, 5),
        "main_category": random.choice(list(CATS)),
        "last_audit_date": messy_date(audit, blank_prob=0.12),
        "certification_status": random.choice(["Certified", "Certified", "Certified", "Pending"])})

suppliers[0].update(main_category="Dairy", certification_status="Certified")   # S-01 Meadow Valley
suppliers[1]["country"] = "NZ"
suppliers[4]["country"] = "N.Z."
suppliers[7]["country"] = "AUS"
suppliers[2]["supplier_rating"] = None
suppliers[5]["supplier_rating"] = 0
suppliers[9]["supplier_rating"] = 6
# duplicate entity under a second ID with a name variant
suppliers.append({**suppliers[0], "supplier_id": "S-15", "supplier_name": "MeadowValley Dairy",
                  "supplier_rating": 3, "last_audit_date": None, "certification_status": ""})
df_suppliers = pd.DataFrame(suppliers)

MEADOW = "S-01"

# ---------- 3. Batches (300 rows) --------------------------------------------
SHELF = {"Chilled": (35, 90), "Frozen": (270, 450), "Ambient": (150, 400)}
ZONES = {"Chilled": "C", "Frozen": "F", "Ambient": "A"}
PREFIX = {p["product_id"]: "".join(w[0] for w in str(p["product_name"]).split()[:2]).upper()
          for p in products}

real_products = [p for p in products if p["product_id"] != "P-014B" and "B" not in p["product_id"][2:]]
batches = []
for i in range(1, 300):
    p = random.choice(real_products)
    storage = "Chilled" if "hill" in str(p["storage_type"]) or p["storage_type"] in ("Fridge", "CHILLED", "chilled") else \
              ("Frozen" if str(p["storage_type"]).lower() == "frozen" else "Ambient")
    lo, hi = SHELF[storage]
    # bias 30% of batches to expire within ~90 days of today
    if random.random() < 0.30:
        exp = rdate(TODAY - timedelta(days=10), TODAY + timedelta(days=90))
        man = exp - timedelta(days=random.randint(lo, hi))
    else:
        man = rdate(date(2025, 1, 15), TODAY - timedelta(days=5))
        exp = man + timedelta(days=random.randint(lo, hi))
    qty = random.choice([120, 240, 360, 480, 600, 960])
    days_in = (TODAY - man).days
    rem = max(0, int(qty * max(0.0, 1 - days_in / random.randint(60, 240)) * random.uniform(0.6, 1.1)))
    supplier = MEADOW if p["product_category"] == "Dairy" and random.random() < 0.6 else \
        random.choice([s["supplier_id"] for s in suppliers[:14]])
    batches.append({
        "batch_id": f"B-{i:04d}", "product_id": p["product_id"], "supplier_id": supplier,
        "batch_number": f"{PREFIX[p['product_id']]}-{man.strftime('%y%m')}-{random.choice('ABCD')}",
        "manufacture_date": messy_date(man), "expiry_date": messy_date(exp, blank_prob=0.03),
        "quantity_received": qty, "quantity_remaining": min(rem, qty),
        "warehouse_location": f"{ZONES[storage]}{random.randint(1,3)}-{random.choice('ABCD')}{random.randint(1,6)}",
        "quality_status": random.choices(["Passed", "Failed", "Pending", "Hold", ""],
                                         [0.82, 0.05, 0.05, 0.03, 0.05])[0],
        "document_status": random.choices(["Complete", "Incomplete", "Missing", ""],
                                          [0.7, 0.15, 0.08, 0.07])[0]})

# deliberate mess
for b in random.sample(batches, 15):
    b["batch_number"] = None                                   # ~5% missing batch numbers
batches[10]["quantity_received"] = -120                        # negative
batches[25]["quantity_received"] = 48000                       # absurd
for b in random.sample(batches, 4):
    b["quantity_remaining"] = int(b["quantity_received"]) + random.randint(20, 100) \
        if isinstance(b["quantity_received"], int) and b["quantity_received"] > 0 else b["quantity_remaining"]
batches[40]["manufacture_date"], batches[40]["expiry_date"] = \
    batches[40]["expiry_date"], batches[40]["manufacture_date"]          # manufacture after expiry
batches[55]["warehouse_location"] = "A1-C2"                    # chilled stock in ambient zone (check product!)

# THE recall batch — B-0187 / YD-2408-A (overwrite index 186)
batches[186] = {
    "batch_id": "B-0187", "product_id": YOG["product_id"], "supplier_id": MEADOW,
    "batch_number": "YD-2408-A", "manufacture_date": "2026-06-08",
    "expiry_date": "2026-08-07", "quantity_received": 480, "quantity_remaining": 152,
    "warehouse_location": "C2-A4", "quality_status": "Passed", "document_status": "Incomplete"}
df_batches = pd.DataFrame(batches)

# ---------- 4. Customers (71 rows incl. 1 duplicate) --------------------------
CTYPES = ["Supermarket", "Dairy", "Cafe", "Restaurant", "Small Retailer"]
CN1 = ["Harbourview", "Ponsonby", "Riccarton", "Te Rapa", "Newtown", "Mount", "Lakeside",
       "Victoria St", "Greenlane", "Papamoa", "Karori", "Sumner", "North End", "Dominion Rd",
       "Fernhill", "Bayfair", "Kelburn", "Addington", "Remuera", "Tawa"]
CN2 = {"Supermarket": "SuperMart", "Dairy": "Corner Dairy", "Cafe": "Espresso Bar",
       "Restaurant": "Kitchen", "Small Retailer": "Foodstore"}
FIRST = ["Sarah", "James", "Aroha", "Mike", "Priya", "Tom", "Emma", "Rawiri", "Lucy", "Dan",
         "Mei", "Sam", "Kiri", "Alex", "Nina"]
LAST = ["Ng", "Smith", "Patel", "Williams", "Kaur", "Henare", "Brown", "Lee", "Walker", "Singh"]

customers = []
for i in range(1, 71):
    ctype = random.choice(CTYPES)
    region = random.choice(REGIONS)
    customers.append({
        "customer_id": f"C-{i:03d}",
        "customer_name": f"{random.choice(CN1)} {CN2[ctype]}",
        "customer_type": ctype, "region": messy_region(region),
        "contact_person": f"{random.choice(FIRST)} {random.choice(LAST)}" if random.random() > 0.1 else "",
        "account_status": random.choices(["Active", "On hold", "Closed"], [0.88, 0.06, 0.06])[0]})
customers[31].update(customer_name="Ponsonby Corner Dairy", customer_type="Dairy",
                     region="Auckland", account_status="Active")
customers.append({**customers[31], "customer_id": "C-071",
                  "customer_name": "Ponsonby Cnr Dairy", "region": "Akl"})   # duplicate entity
for c in random.sample(customers, 5):
    c["customer_type"] = "Café" if c["customer_type"] == "Cafe" else c["customer_type"]
customers[43]["account_status"] = "Closed"                    # will receive orders anyway
df_customers = pd.DataFrame(customers)

# ---------- 5. Orders (~1800 rows) --------------------------------------------
prod_batches = {}
for b in batches:
    prod_batches.setdefault(b["product_id"], []).append(b["batch_id"])
price = {p["product_id"]: float(p["unit_sell_price"]) for p in products}

orders = []
oid = 0
for _ in range(1780):
    oid += 1
    p = random.choice(real_products)
    c = random.choice(customers)
    od = rdate(date(2025, 1, 20), TODAY - timedelta(days=1))
    dd = od + timedelta(days=random.randint(0, 3))
    qty = random.choice([6, 12, 24, 24, 36, 48, 72])
    val = round(qty * price[p["product_id"]] * random.choice([1, 1, 1, 1, 0.95]), 2)
    batch = random.choice(prod_batches.get(p["product_id"], [None]))
    if random.random() < 0.16:
        batch = None                                          # traceability killer
    orders.append({
        "order_id": f"O-{oid:05d}", "customer_id": c["customer_id"],
        "order_date": messy_date(od), "dispatch_date": messy_date(dd, blank_prob=0.05),
        "product_id": p["product_id"], "batch_id": batch, "quantity_sold": qty,
        "sales_value": val, "delivery_region": messy_region(random.choice(REGIONS))
        if random.random() < 0.12 else str(c["region"]).strip() if c["region"] else "Auckland"})

# recall batch orders: 14 orders of B-0187 across regions/types, 10 Jun – 5 Jul 2026
yog_price = price[YOG["product_id"]]
for k in range(14):
    oid += 1
    c = random.choice([c for c in customers[:70] if c["account_status"] == "Active"])
    od = rdate(date(2026, 6, 10), date(2026, 7, 5))
    qty = random.choice([12, 24, 24, 36])
    orders.append({
        "order_id": f"O-{oid:05d}", "customer_id": c["customer_id"],
        "order_date": messy_date(od), "dispatch_date": messy_date(od + timedelta(days=1)),
        "product_id": YOG["product_id"], "batch_id": "B-0187", "quantity_sold": qty,
        "sales_value": round(qty * yog_price, 2),
        "delivery_region": str(c["region"]).strip() if c["region"] else "Auckland"})
# 5 yoghurt orders in the same window with NO batch id (the ambiguity that matters)
for k in range(5):
    oid += 1
    c = random.choice(customers[:70])
    od = rdate(date(2026, 6, 10), date(2026, 7, 5))
    qty = random.choice([12, 24])
    orders.append({
        "order_id": f"O-{oid:05d}", "customer_id": c["customer_id"],
        "order_date": messy_date(od), "dispatch_date": messy_date(od + timedelta(days=1)),
        "product_id": YOG["product_id"], "batch_id": None, "quantity_sold": qty,
        "sales_value": round(qty * yog_price, 2),
        "delivery_region": str(c["region"]).strip() if c["region"] else "Auckland"})

# deliberate mess
orders[100]["customer_id"] = "C-999"                          # orphan customer
orders[200]["customer_id"] = "C-888"
orders[300]["quantity_sold"] = 0
orders[400]["quantity_sold"] = -24
o = orders[500]                                               # dispatch before order
o["order_date"], o["dispatch_date"] = "2026-03-14", "2026-03-10"
orders.append(dict(orders[650]))                              # exact duplicate row
df_orders = pd.DataFrame(orders)

# ---------- 6. Complaints (100 rows) ------------------------------------------
CTYPE_MESS = ["Taste/Quality", "Taste / Quality", "taste quality", "Packaging", "Packaging damage",
              "Expiry on delivery", "Short dated", "Foreign object", "Temperature", "Warm on arrival",
              "Wrong item"]
SEV = ["Low", "Medium", "med", "High", "HIGH", "Critical"]
complaints = []
for i in range(1, 99):
    o = random.choice(orders[:1780])
    cd = rdate(date(2025, 2, 1), TODAY)
    status = random.choices(["Open", "In progress", "Resolved", "Closed", "closed", ""],
                            [0.12, 0.1, 0.45, 0.2, 0.05, 0.08])[0]
    res = random.randint(1, 21) if status in ("Resolved", "Closed", "closed") else None
    if status in ("Resolved", "Closed") and random.random() < 0.15:
        res = None                                            # resolved but no resolution days
    complaints.append({
        "complaint_id": f"CMP-{i:03d}", "customer_id": o["customer_id"],
        "product_id": o["product_id"] if random.random() > 0.04 else None,
        "batch_id": o["batch_id"] if random.random() > 0.30 else None,   # ~30% unlinked
        "complaint_date": messy_date(cd),
        "complaint_type": random.choice(CTYPE_MESS),
        "severity": random.choice(SEV), "complaint_status": status,
        "resolution_days": res})
complaints[20]["resolution_days"] = -3                        # negative
# recall-relevant complaints
complaints.append({
    "complaint_id": "CMP-099", "customer_id": orders[1785]["customer_id"],
    "product_id": YOG["product_id"], "batch_id": "B-0187",
    "complaint_date": "2026-07-06", "complaint_type": "Taste/Quality",
    "severity": "Medium", "complaint_status": "Open", "resolution_days": None})
complaints.append({
    "complaint_id": "CMP-100", "customer_id": orders[1796]["customer_id"],
    "product_id": YOG["product_id"], "batch_id": None,        # same product, no batch — ambiguous
    "complaint_date": "2026-07-08", "complaint_type": "Warm on arrival",
    "severity": "High", "complaint_status": "Open", "resolution_days": None})
df_complaints = pd.DataFrame(complaints)

# ---------- 7. Supplier Documents (~50 rows) -----------------------------------
DOCTYPES = ["HACCP Cert", "Food Safety Audit", "Insurance", "Product Spec", "Temperature Declaration"]
DOC_MESS = {"HACCP Cert": ["HACCP Cert", "HACCP Certificate", "haccp cert"],
            "Food Safety Audit": ["Food Safety Audit", "FS Audit"],
            "Insurance": ["Insurance", "Insurance Cert"],
            "Product Spec": ["Product Spec", "Product Specification"],
            "Temperature Declaration": ["Temperature Declaration", "Temp Declaration"]}
docs = []
did = 0
for s in suppliers[:14]:
    # deliberate missing-RECORD gaps: S-07 has no Food Safety Audit, S-11 no Insurance
    types = [t for t in DOCTYPES
             if not (s["supplier_id"] == "S-07" and t == "Food Safety Audit")
             and not (s["supplier_id"] == "S-11" and t == "Insurance")]
    for t in random.sample(types, random.randint(3, len(types))):
        did += 1
        issue = rdate(date(2023, 6, 1), date(2026, 4, 1))
        exp = issue + timedelta(days=365 * random.choice([1, 1, 2]))
        status = "Valid" if exp > TODAY else "Expired"
        if random.random() < 0.08:
            status = ""                                       # blank status
        docs.append({
            "document_id": f"DOC-{did:03d}", "supplier_id": s["supplier_id"],
            "document_type": random.choice(DOC_MESS[t]),
            "issue_date": messy_date(issue), "expiry_date": messy_date(exp, blank_prob=0.06),
            "document_status": status,
            "related_category": s["main_category"]})
# contradictions: marked Valid but expiry clearly past
for d in random.sample([d for d in docs if d["expiry_date"]], 3):
    d["document_status"], d["expiry_date"] = "Valid", "2025-02-10"
# Meadow Valley: expired Temperature Declaration (supplier sheet still says Certified)
did += 1
docs.append({"document_id": f"DOC-{did:03d}", "supplier_id": MEADOW,
             "document_type": "Temperature Declaration", "issue_date": "2024-05-20",
             "expiry_date": "2025-05-20", "document_status": "Expired",
             "related_category": "Dairy"})
df_docs = pd.DataFrame(docs)

# ---------- 8. Recall Risk (30 rows) -------------------------------------------
REASONS = ["Temperature excursion", "Temp excursion", "Missing docs", "Missing documents",
           "Complaint cluster", "Failed QC", "Supplier notice", "Near expiry"]
LEVELS = ["Low", "Medium", "medium", "High", "HIGH", "Critical"]
ACTIONS = ["Hold stock", "Contact customers", "Chase documents", "Monitor", "Dispose", ""]
risks = []
for i in range(1, 29):
    b = random.choice(batches)
    risks.append({
        "risk_id": f"RR-{i:03d}", "batch_id": b["batch_id"],
        "risk_reason": random.choice(REASONS), "risk_level": random.choice(LEVELS),
        "date_identified": messy_date(rdate(date(2025, 3, 1), TODAY)),
        "action_required": random.choice(ACTIONS),
        "status": random.choices(["Open", "In progress", "Closed", ""], [0.3, 0.15, 0.45, 0.1])[0]})
risks[5]["batch_id"] = "B-9999"                               # orphan batch
# Meadow Valley PRIOR issue — earlier batch, closed (history for the scenario)
meadow_prior = next(b["batch_id"] for b in batches
                    if b["supplier_id"] == MEADOW and b["batch_id"] != "B-0187")
risks.append({"risk_id": "RR-029", "batch_id": meadow_prior,
              "risk_reason": "Temperature excursion", "risk_level": "High",
              "date_identified": "2025-11-03", "action_required": "Hold stock",
              "status": "Closed"})
risks.append({"risk_id": "RR-030", "batch_id": meadow_prior,
              "risk_reason": "Missing docs", "risk_level": "Medium",
              "date_identified": "2026-02-17", "action_required": "Chase documents",
              "status": "Open"})
df_risks = pd.DataFrame(risks)

# ---------- write workbook -----------------------------------------------------
OUT = "raw/freshroute_raw_data.xlsx"
with pd.ExcelWriter(OUT, engine="openpyxl") as xl:
    df_products.to_excel(xl, sheet_name="Products", index=False)
    df_suppliers.to_excel(xl, sheet_name="Suppliers", index=False)
    df_batches.to_excel(xl, sheet_name="Batches", index=False)
    df_customers.to_excel(xl, sheet_name="Customers", index=False)
    df_orders.to_excel(xl, sheet_name="Orders", index=False)
    df_complaints.to_excel(xl, sheet_name="Complaints", index=False)
    df_docs.to_excel(xl, sheet_name="Supplier_Documents", index=False)
    df_risks.to_excel(xl, sheet_name="Recall_Risk", index=False)

print("rows:", {n: len(d) for n, d in [("Products", df_products), ("Suppliers", df_suppliers),
      ("Batches", df_batches), ("Customers", df_customers), ("Orders", df_orders),
      ("Complaints", df_complaints), ("Docs", df_docs), ("RecallRisk", df_risks)]})
print("YD-2408-A orders:", (df_orders["batch_id"] == "B-0187").sum(),
      "| yoghurt orders w/o batch:", ((df_orders["product_id"] == YOG["product_id"])
                                      & df_orders["batch_id"].isna()).sum(),
      "| orders missing batch overall: %.1f%%" % (100 * df_orders["batch_id"].isna().mean()))
