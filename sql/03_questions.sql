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