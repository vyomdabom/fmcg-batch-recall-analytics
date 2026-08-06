/* ============================================================
   create_tables.sql — FMCG Batch & Recall Risk Analytics
   Dialect: PostgreSQL
   Task ref: sql_tasks.md A1–A2
   ============================================================ */

DROP TABLE IF EXISTS recall_risk_exceptions CASCADE;
DROP TABLE IF EXISTS orders_exceptions CASCADE;
DROP TABLE IF EXISTS batches_exceptions CASCADE;
DROP TABLE IF EXISTS recall_risk CASCADE;
DROP TABLE IF EXISTS supplier_documents CASCADE;
DROP TABLE IF EXISTS complaints CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS batches CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- products (column order matches data/cleaned/csv/products.csv — brand before storage_type)
CREATE TABLE products(
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(100) NOT NULL,
    brand VARCHAR(100),
    storage_type VARCHAR(100) NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    unit_sell_price DECIMAL(10, 2) NOT NULL,
    active_status VARCHAR(20)
);

-- suppliers
CREATE TABLE suppliers(
    supplier_id VARCHAR(10) PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    country VARCHAR(20) NOT NULL,
    supplier_rating NUMERIC(3, 1),
    main_category VARCHAR(50),
    last_audit_date Date,
    certification_status VARCHAR(30)
);

-- customers
CREATE TABLE customers(
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    customer_type VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    contact_person VARCHAR(50),
    account_status VARCHAR(50)
);

-- batches (FKs → products, suppliers)
CREATE TABLE batches(
    batch_id VARCHAR(10) PRIMARY KEY,
    product_id VARCHAR(10),
    supplier_id VARCHAR(10),
    batch_number VARCHAR(20),
    manufacture_date DATE,
    expiry_date DATE,
    quantity_received INTEGER,
    quantity_remaining INTEGER,
    warehouse_location VARCHAR(10),
    quality_status VARCHAR(10),
    document_status VARCHAR(50),
    CONSTRAINT fk_batch_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_batch_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT chk_batch_dates CHECK (expiry_date > manufacture_date)
);

-- orders (FKs → customers, products, batches; batch_id NULLABLE — deliberate)
CREATE TABLE orders(
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    order_date DATE,
    dispatch_date DATE,
    product_id VARCHAR(20),
    batch_id VARCHAR(30),
    quantity_sold INTEGER,
    sales_value DECIMAL(10, 2),
    delivery_region VARCHAR(50),
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_order_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_order_batch FOREIGN KEY (batch_id) REFERENCES batches(batch_id),
    CONSTRAINT chk_dispatch CHECK (
        dispatch_date IS NULL
        OR dispatch_date >= order_date
    )
);

-- complaints (nullable FKs → batches, products)
CREATE TABLE complaints(
    complaint_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    batch_id VARCHAR(30),
    complaint_date DATE,
    complaint_type VARCHAR(100),
    severity VARCHAR(20),
    complaint_status VARCHAR(50),
    resolution_days INTEGER,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
);

-- supplier_documents
CREATE TABLE supplier_documents (
    document_id VARCHAR(30) PRIMARY KEY,
    supplier_id VARCHAR(30) NOT NULL,
    document_type VARCHAR(50),
    issue_date DATE,
    expiry_date DATE,
    document_status VARCHAR(30),
    related_category VARCHAR(50),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CHECK (
        expiry_date IS NULL
        OR issue_date IS NULL
        OR expiry_date >= issue_date
    )
);

-- recall_risk
CREATE TABLE recall_risk (
    risk_id VARCHAR(30) PRIMARY KEY,
    batch_id VARCHAR(30) NOT NULL,
    risk_reason TEXT,
    risk_level VARCHAR(20),
    date_identified DATE,
    action_required TEXT,
    status VARCHAR(30),
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
);

-- batches_exceptions: rows rejected at import (no constraints — holds the bad data as-is)
CREATE TABLE batches_exceptions (
    batch_id VARCHAR(10),
    product_id VARCHAR(10),
    supplier_id VARCHAR(10),
    batch_number VARCHAR(20),
    manufacture_date DATE,
    expiry_date DATE,
    quantity_received INTEGER,
    quantity_remaining INTEGER,
    warehouse_location VARCHAR(10),
    quality_status VARCHAR(10),
    document_status VARCHAR(50),
    exception_reason VARCHAR(150)
);

-- orders_exceptions
CREATE TABLE orders_exceptions(
    order_id VARCHAR(20),
    customer_id VARCHAR(10),
    order_date DATE,
    dispatch_date DATE,
    product_id VARCHAR(20),
    batch_id VARCHAR(30),
    quantity_sold INTEGER,
    sales_value DECIMAL(10, 2),
    delivery_region VARCHAR(50),
    exception_reason VARCHAR(150)
);

-- recall_risk_exceptions
CREATE TABLE recall_risk_exceptions(
    risk_id VARCHAR(30),
    batch_id VARCHAR(30),
    risk_reason TEXT,
    risk_level VARCHAR(20),
    date_identified DATE,
    action_required TEXT,
    status VARCHAR(30),
    exception_reason VARCHAR(150)
);

-- Data import (task A2): cleaned CSVs from data/cleaned/csv/ loaded into these tables.
-- Import decisions and exceptions are documented in import_log.md.
