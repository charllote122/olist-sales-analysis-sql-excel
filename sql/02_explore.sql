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