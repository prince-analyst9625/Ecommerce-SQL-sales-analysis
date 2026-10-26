-- E-commerce Sales Analysis | MySQL 8.0+
-- Business rule: for the main sales/revenue analysis, count only Delivered orders.
-- Net item sales = quantity * unit_price * (1 - discount_pct / 100).
-- Shipping fees are excluded from product revenue unless a query says otherwise.
USE ecommerce_analytics;

-- ================================================================
-- SECTION 1: BASIC SQL + AGGREGATES
-- ================================================================

-- 1. Preview the customers table.
SELECT * FROM customers LIMIT 10;

-- 2. How many rows are in each order status?
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- 3. How many customers are registered in each state?
SELECT state, COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;

-- 4. Total revenue from delivered orders.
SELECT ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS delivered_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered';

-- 5. Monthly revenue trend (delivered orders only).
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- 6. Which product categories generate the most revenue?
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY revenue DESC;

-- 7. Top 10 products by delivered revenue.
SELECT p.product_id, p.product_name,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- ================================================================
-- SECTION 2: JOINS + BUSINESS QUESTIONS
-- ================================================================

-- 8. Revenue by customer city.
SELECT c.city, c.state,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city, c.state
ORDER BY revenue DESC;

-- 9. Top 10 customers by delivered revenue.
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS delivered_orders,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS lifetime_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_revenue DESC
LIMIT 10;

-- 10. Average order value (AOV), using delivered orders only.
-- First calculate each order's value, then average those order values.
SELECT ROUND(AVG(order_revenue), 2) AS average_order_value
FROM (
    SELECT o.order_id,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)) AS order_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.order_id
) AS order_totals;

-- 11. Find customers who have never placed an order.
SELECT c.customer_id, c.customer_name, c.city
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- 12. Find products that have never appeared in any order item.
SELECT p.product_id, p.product_name, p.category
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL
ORDER BY p.product_id;

-- 13. Estimate gross profit by category for delivered sales.
-- This uses the product's listed cost_price as an estimate, not historical accounting cost.
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS revenue,
       ROUND(SUM(oi.quantity * p.cost_price), 2) AS estimated_cost,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100))
             - SUM(oi.quantity * p.cost_price), 2) AS estimated_gross_profit
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY estimated_gross_profit DESC;

-- 14. Count payment methods and total successfully paid amount.
SELECT payment_method,
       COUNT(*) AS transaction_count,
       SUM(CASE WHEN payment_status = 'Paid' THEN amount ELSE 0 END) AS total_paid_amount
FROM payments
GROUP BY payment_method
ORDER BY total_paid_amount DESC;

-- ================================================================
-- SECTION 3: HAVING + CASE + SUBQUERIES / CTEs
-- ================================================================

-- 15. Customers with at least 2 delivered orders.
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS delivered_order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) >= 2
ORDER BY delivered_order_count DESC, c.customer_name;

-- 16. Order-level sales above ₹5,000.
WITH order_totals AS (
    SELECT o.order_id, o.order_date, o.order_status,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)) AS order_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.order_date, o.order_status
)
SELECT order_id, order_date, ROUND(order_revenue, 2) AS order_revenue
FROM order_totals
WHERE order_status = 'Delivered' AND order_revenue > 5000
ORDER BY order_revenue DESC;

-- 17. Label customers by spending level (delivered orders only).
WITH customer_spend AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 0) AS revenue
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.order_status = 'Delivered'
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(revenue, 2) AS revenue,
       CASE WHEN revenue >= 10000 THEN 'High Value'
            WHEN revenue >= 4000 THEN 'Mid Value'
            ELSE 'Low Value' END AS customer_segment
FROM customer_spend
ORDER BY revenue DESC;

-- ================================================================
-- SECTION 4: WINDOW FUNCTIONS
-- ================================================================

-- 18. Rank products within each category by revenue.
WITH product_sales AS (
    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT category, product_name, ROUND(revenue, 2) AS revenue,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank
FROM product_sales
ORDER BY category, category_rank;

-- 19. Month-over-month revenue and percentage change.
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
), revenue_with_previous_month AS (
    SELECT month, revenue,
           LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT month, ROUND(revenue, 2) AS revenue,
       ROUND(previous_month_revenue, 2) AS previous_month_revenue,
       ROUND(100 * (revenue - previous_month_revenue) / NULLIF(previous_month_revenue, 0), 2) AS mom_growth_pct
FROM revenue_with_previous_month
ORDER BY month;

-- 20. Each category's percentage contribution to total delivered revenue.
WITH category_revenue AS (
    SELECT p.category,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.category
)
SELECT category, ROUND(revenue, 2) AS revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct
FROM category_revenue
ORDER BY revenue DESC;

-- 21. Rolling 3-month delivered revenue (includes current month and prior two available months).
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT month, ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3_month_revenue
FROM monthly_revenue
ORDER BY month;

-- ================================================================
-- SECTION 5: DATA QUALITY / FINAL CHECKS
-- ================================================================

-- 22. Order counts by status with an order cancellation rate.
SELECT COUNT(*) AS all_orders,
       SUM(order_status = 'Cancelled') AS cancelled_orders,
       ROUND(100 * SUM(order_status = 'Cancelled') / COUNT(*), 2) AS cancellation_rate_pct
FROM orders;

-- 23. Return rate as a percentage of all orders.
SELECT COUNT(*) AS all_orders,
       SUM(order_status = 'Returned') AS returned_orders,
       ROUND(100 * SUM(order_status = 'Returned') / COUNT(*), 2) AS return_rate_pct
FROM orders;

-- 24. Payments by status, including the number and sum of transactions.
SELECT payment_status, COUNT(*) AS transaction_count,
       ROUND(SUM(amount), 2) AS recorded_amount
FROM payments
GROUP BY payment_status
ORDER BY transaction_count DESC;

-- 25. Basic referential sanity check: every order should have one payment row.
SELECT COUNT(*) AS orders_missing_payment
FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE p.order_id IS NULL;
