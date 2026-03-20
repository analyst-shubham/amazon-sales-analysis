-- Tools: PostgreSQL, Excel
-- Author: Shubham
-- =========================
-- AMAZON SALES ANALYSIS
-- =========================

-- SECTION 1: DATA EXPLORATION

-- Checking the data
SELECT * FROM orders LIMIT 20;

SELECT SUM(total_amount) as total_revenue, 
COUNT(*) as total_orders, 
SUM(quantity) as units_sold
FROM orders;

-- Checking for Total rows
SELECT COUNT(*) FROM orders;
--RESULT: 1 Lakh rows, i.e data sucessfully imported.

-- Show Distinct payment methods
SELECT DISTINCT payment_method FROM orders;

-- Show Distinct Categories
SELECT DISTINCT category FROM orders;

-- SECTION 2: DATA CLEANING--------------------

--Check for null values
SELECT * FROM orders
WHERE payment_method IS NULL;
--RESULT: No null values found. 

--Standardize the Payment Names 
SELECT DISTINCT LOWER(payment_method) FROM orders;

-- Remove duplicates
SELECT DISTINCT * FROM orders;

-- SECTION 3: KPI------------------------------------

--Total Revenue
SELECT SUM(total_amount) AS total_revenue FROM orders;

--Net Sales
SELECT SUM(unit_price * quantity * (1 - discount)) AS net_sales
FROM orders;

--Total Orders
SELECT COUNT(*) AS total_orders FROM orders;

--Total Units Sold 
SELECT SUM(quantity) AS units_sold FROM orders;

--Average Order Value 
SELECT AVG(total_amount) AS avg_order_value FROM orders;

-- Total Discount 
SELECT SUM(unit_price * quantity * discount) AS total_discount
FROM orders;

-- SECTION 4: BUSINESS ANALYSIS-------------------------

--Revenue & Percentage share by Categories
SELECT category, SUM(total_amount) AS revenue
FROM orders
GROUP BY category 
ORDER BY revenue DESC;

SELECT category, SUM(total_amount) AS revenue,
ROUND(
    SUM(total_amount) * 100.0 
    / SUM(SUM(total_amount)) OVER(), 2) AS pct_share
FROM orders GROUP BY category ORDER BY pct_share DESC;

--Payment Methods analysis
SELECT payment_method, 
SUM(total_amount) AS revenue, 
ROUND(SUM(total_amount)*100.0 / SUM(SUM(total_amount)) OVER(),2) AS pct_share 
FROM orders 
GROUP BY payment_method
ORDER BY pct_share DESC

--Top 5 products
SELECT product_name, 
SUM(total_amount) AS revenue FROM orders 
GROUP BY product_name 
ORDER BY revenue DESC 
LIMIT 5;

--Brand Performance 
SELECT brand, SUM(total_amount) AS revenue 
FROM orders 
GROUP BY brand ORDER BY revenue DESC;

-- Monthly revenue trend 
SELECT DATE_TRUNC('month', order_date) AS month, 
TO_CHAR(order_date, 'Month') as mon_name,
SUM(total_amount) AS revenue FROM orders 
GROUP BY month, mon_name
ORDER BY month;

--Brand Ranking
SELECT brand, 
SUM(total_amount) AS revenue, 
RANK() OVER (ORDER BY SUM(total_amount) DESC) AS rank 
FROM orders 
GROUP BY brand;

--Top Category per year 
SELECT year, category, revenue
FROM (
    SELECT EXTRACT(YEAR FROM order_date) AS year,
        category, SUM(total_amount) AS revenue,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM order_date) 
            ORDER BY SUM(total_amount) DESC
        ) AS rank
    FROM orders
    GROUP BY year, category
) t
WHERE rank = 1
ORDER BY year;