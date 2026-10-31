-- ==========================================
-- Olist sales analysis: create tables and load data
-- Run from the repo root with psql (the \copy lines only work in psql):
--   psql -U postgres -d olist_dataset -f sql/01_create_and_load.sql
-- ==========================================
\set ON_ERROR_STOP on

-- ==========================================
-- 1. SETUP SCHEMA
-- ==========================================
CREATE SCHEMA IF NOT EXISTS olist;

-- ==========================================
-- 2. CREATE TABLES
-- ==========================================

-- Customers
DROP TABLE IF EXISTS olist.customers;
CREATE TABLE olist.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(5),   -- text, so leading zeros are kept
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- Sellers
DROP TABLE IF EXISTS olist.sellers;
CREATE TABLE olist.sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(5),     -- text, so leading zeros are kept
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- Products
DROP TABLE IF EXISTS olist.products;
CREATE TABLE olist.products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,           -- spelling matches the CSV header
    product_description_lenght INTEGER,    -- spelling matches the CSV header
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- Product Category Translation
DROP TABLE IF EXISTS olist.product_category_translation;
CREATE TABLE olist.product_category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- Orders
DROP TABLE IF EXISTS olist.orders;
CREATE TABLE olist.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Order Items (Composite Primary Key)
DROP TABLE IF EXISTS olist.order_items;
CREATE TABLE olist.order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);

-- Payments (Composite Primary Key)
DROP TABLE IF EXISTS olist.payments;
CREATE TABLE olist.payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(20),
    payment_installments INTEGER,
    payment_value NUMERIC(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- Reviews (no primary key: review_id repeats in this dataset)
DROP TABLE IF EXISTS olist.reviews;
CREATE TABLE olist.reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- ==========================================
-- 3. LOAD DATA
-- ==========================================
\copy olist.customers FROM 'data/raw/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy olist.sellers FROM 'data/raw/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy olist.products FROM 'data/raw/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy olist.product_category_translation FROM 'data/raw/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy olist.orders FROM 'data/raw/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy olist.order_items FROM 'data/raw/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy olist.payments FROM 'data/raw/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
\copy olist.reviews FROM 'data/raw/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- ==========================================
-- 4. CHECK ROW COUNTS
-- ==========================================
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM olist.customers
UNION ALL SELECT 'sellers', COUNT(*) FROM olist.sellers
UNION ALL SELECT 'products', COUNT(*) FROM olist.products
UNION ALL SELECT 'product_category_translation', COUNT(*) FROM olist.product_category_translation
UNION ALL SELECT 'orders', COUNT(*) FROM olist.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM olist.order_items
UNION ALL SELECT 'payments', COUNT(*) FROM olist.payments
UNION ALL SELECT 'reviews', COUNT(*) FROM olist.reviews
ORDER BY table_name;