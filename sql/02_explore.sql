-- ==========================================
-- 02_explore.sql
-- Data quality checks before the analysis
-- ==========================================

-- a) Orders per status
-- Why: decides which orders count as a sale (I plan to use delivered orders only).
SELECT order_status, COUNT(*) AS orders
FROM olist.orders
GROUP BY order_status
ORDER BY orders DESC;

-- b) Date range of the data
-- Why: shows the first and last order, so I know which months the charts will cover
--      and whether the last month is only partly there.
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM olist.orders;

-- c) Orders per month
-- Why: finds months with very few orders (start and end of the data), which would
--      look like a sales drop on a trend chart but are really missing data.
SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
       COUNT(*) AS orders
FROM olist.orders
GROUP BY 1
ORDER BY 1;

-- d) Orders with no delivery date
-- Why: these cannot be used for delivery time or late-delivery questions.
SELECT COUNT(*) AS no_delivery_date
FROM olist.orders
WHERE order_delivered_customer_date IS NULL;

-- d2) Delivered orders with no delivery date
-- Why: these are the ones that would break the delivery time and review questions.
SELECT COUNT(*) AS delivered_no_date
FROM olist.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- e) Review text encoding check
-- Why: accents such as "é" and "ã" must read correctly. Garbled text such as "Ã©"
--      or "Ã£" means the file was loaded with the wrong encoding.
--      Note: a capital "Ã" alone is normal (NÃO, SÃO), so the check looks for
--      "Ã" followed by a symbol character.

-- e1) Look at real review text
SELECT review_comment_message
FROM olist.reviews
WHERE review_comment_message IS NOT NULL
LIMIT 10;

-- e2) Count garbled reviews ("Ã" followed by a symbol, such as Ã© Ã£ Ã§ Ã¡)
SELECT COUNT(*) AS garbled
FROM olist.reviews
WHERE review_comment_message ~ 'Ã[ -¿]';

-- f) Product categories with no English translation
-- Why: an INNER JOIN would drop these products, so the join must be a LEFT JOIN.
SELECT DISTINCT p.product_category_name
FROM olist.products p
LEFT JOIN olist.product_category_translation t
       ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;