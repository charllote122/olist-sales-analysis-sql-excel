-- Q1a) How many delivered orders are there?

SELECT COUNT(*)
FROM olist.orders
WHERE  order_status = 'delivered';

   -- Q1b) Total price of ALL order items (before filtering for delivered)
SELECT SUM(price)
FROM olist.order_items;

-- Q1c) Preview: connect each item to its order
SELECT o.order_id,o.order_status,i.price
FROM olist.orders o 
JOIN olist.order_items i
ON o.order_id = i.order_id
LIMIT 10;

-- Q1d) Total revenue from delivered orders
SELECT SUM(price)
FROM olist.orders o
JOIN olist.order_items i
ON o.order_id = i.order_id
WHERE order_status = 'delivered';

-- Q1e) Delivered orders and revenue, together
SELECT COUNT(*) AS delivered_orders,
       SUM(i.price) AS revenue
FROM olist.orders o
JOIN olist.order_items i
  ON o.order_id = i.order_id
WHERE o.order_status = 'delivered';

-- Q1f) Delivered orders and revenue, together (correct count)

SELECT COUNT(DISTINCT o.order_id) AS delivered_orders,
       SUM(i.price) AS revenue
FROM olist.orders o
JOIN olist.order_items i
  ON o.order_id = i.order_id
WHERE o.order_status = 'delivered';

   -- Q1 ANSWER: 96,478 delivered orders, revenue 13,221,498.11
   -- (COUNT(DISTINCT) is needed because an order can have several items)


-- ==========================================
-- Q2) What are orders and revenue per month?
-- ==========================================

-- Q2a) Delivered orders per month
SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
       COUNT(*) AS orders
FROM olist.orders
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- Q2b) Delivered orders and revenue per month
SELECT DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(i.price) AS revenue
FROM olist.orders o
JOIN olist.order_items i
  ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- Q2c) Delivered orders and revenue per month, Jan 2017 to Aug 2018 (for the chart)
SELECT DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(i.price) AS revenue
FROM olist.orders o
JOIN olist.order_items i
  ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
GROUP BY month
ORDER BY month;

-- Q3a) Preview: each item with its product category
SELECT i.order_id, i.price, p.product_category_name
FROM olist.order_items i
JOIN olist.products p
  ON i.product_id = p.product_id
LIMIT 10;

-- Q3b) Preview: each item with its English category (keeping untranslated ones)
SELECT i.price,
       COALESCE(t.product_category_name_english,
                p.product_category_name,
                'unknown') AS category
FROM olist.order_items i
JOIN olist.products p
  ON i.product_id = p.product_id
LEFT JOIN olist.product_category_translation t
  ON p.product_category_name = t.product_category_name
LIMIT 10;

-- Q3c) Top 10 product categories by revenue (delivered orders)
SELECT COALESCE(t.product_category_name_english,
                p.product_category_name,
                'unknown') AS category,
       SUM(i.price) AS revenue
FROM olist.order_items i
JOIN olist.orders o
  ON i.order_id = o.order_id
JOIN olist.products p
  ON i.product_id = p.product_id
LEFT JOIN olist.product_category_translation t
  ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- Q4) Delivered orders and revenue per customer state
SELECT c.customer_state AS state,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(i.price) AS revenue
FROM olist.order_items i
JOIN olist.orders o
  ON i.order_id = o.order_id
JOIN olist.customers c
  ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY revenue DESC
LIMIT 10;

-- ==========================================
-- Q5) What is the average order value, overall and by state?
-- Average order value (AOV) = total revenue / number of orders.
-- Note: AVG(price) is the average ITEM price, which is not the same thing.
-- ==========================================

-- Q5a) Overall average order value vs average item price (delivered orders)
SELECT ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
       ROUND(AVG(i.price), 2) AS avg_item_price
FROM olist.order_items i
JOIN olist.orders o
  ON i.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- Q5b) Average order value per customer state (all states)
SELECT c.customer_state AS state,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM olist.order_items i
JOIN olist.orders o
  ON i.order_id = o.order_id
JOIN olist.customers c
  ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY avg_order_value DESC;

-- Q5c) Same, but only states with at least 100 delivered orders
-- Why: an average based on a handful of orders is not reliable.
-- HAVING filters AFTER the groups are made (WHERE filters BEFORE).
SELECT c.customer_state AS state,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM olist.order_items i
JOIN olist.orders o
  ON i.order_id = o.order_id
JOIN olist.customers c
  ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY avg_order_value DESC;

-- ==========================================
-- Q6) What share of payments is credit card, boleto, voucher and debit?
-- Measured as money (payment_value) and as number of payments.
-- Delivered orders only.
-- New SQL: a window function, SUM(...) OVER (), to get the grand total
-- next to every group so a percentage can be calculated.
-- ==========================================

-- Q6a) Payments per payment type
SELECT p.payment_type,
       COUNT(*) AS payments,
       ROUND(SUM(p.payment_value), 2) AS total_value
FROM olist.payments p
JOIN olist.orders o
  ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_value DESC;

-- Q6b) Share of each payment type (percentages)
SELECT p.payment_type,
       COUNT(*) AS payments,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_payments,
       ROUND(SUM(p.payment_value), 2) AS total_value,
       ROUND(100.0 * SUM(p.payment_value) / SUM(SUM(p.payment_value)) OVER (), 2) AS pct_of_value
FROM olist.payments p
JOIN olist.orders o
  ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_value DESC;

-- ==========================================
-- Q7) What is the average delivery time, and what percentage of orders arrive late?
-- Delivery time = delivered date - purchase date. Late = delivered after the estimated date.
-- Only delivered orders that actually have a delivery date.
-- New SQL: date arithmetic, CASE WHEN.
-- ==========================================

-- Q7a) Average delivery time in days
SELECT ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400)::numeric, 1) AS avg_delivery_days
FROM olist.orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;

-- Q7b) Percentage of orders delivered late
SELECT COUNT(*) AS delivered_orders,
       SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct
FROM olist.orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;

-- ==========================================
-- Q8) How does the review score change when a delivery is late?
-- Unit here is reviews (an order can have more than one review).
-- ==========================================

SELECT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'late' ELSE 'on time' END AS delivery,
       COUNT(*) AS reviews,
       ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM olist.orders o
JOIN olist.reviews r
  ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery
ORDER BY delivery;

-- ==========================================
-- Q9) What share of customers order more than once?
-- customer_id is a new ID for every order, so a person is identified by customer_unique_id.
-- New SQL: a CTE (WITH ... AS) to build a step-by-step query.
-- ==========================================

WITH per_customer AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS orders
    FROM olist.orders o
    JOIN olist.customers c
      ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT COUNT(*) AS customers,
       SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_pct
FROM per_customer;

-- ==========================================
-- Q10) Who are the top 10 sellers by revenue?
-- ==========================================

-- Q10a) Top 10 sellers
SELECT s.seller_id,
       s.seller_state,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(i.price), 2) AS revenue
FROM olist.order_items i
JOIN olist.orders o
  ON i.order_id = o.order_id
JOIN olist.sellers s
  ON i.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_state
ORDER BY revenue DESC
LIMIT 10;

-- Q10b) How much of all revenue do the top 10 sellers make together?
WITH seller_revenue AS (
    SELECT i.seller_id,
           SUM(i.price) AS revenue
    FROM olist.order_items i
    JOIN olist.orders o
      ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY i.seller_id
),
top10 AS (
    SELECT revenue
    FROM seller_revenue
    ORDER BY revenue DESC
    LIMIT 10
)
SELECT ROUND(100.0 * (SELECT SUM(revenue) FROM top10)
                   / (SELECT SUM(revenue) FROM seller_revenue), 2) AS top10_share_pct;