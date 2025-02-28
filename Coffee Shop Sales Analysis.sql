USE portfolio_projects;
SELECT * FROM coffee_shop_sales;

-- 1. Calculate the total revenue per store by day, and also include the cumulative revenue for each store over time (sorted by transaction date).
SELECT store_id, transaction_date, daily_revenue, SUM(daily_revenue) OVER (PARTITION BY store_id ORDER BY transaction_date) AS cumulative_revenue
FROM (
    SELECT store_id, transaction_date, ROUND(SUM(transaction_qty * unit_price),2) AS daily_revenue
    FROM coffee_shop_sales
    GROUP BY store_id, transaction_date) AS DailyRevenue
	ORDER BY store_id, transaction_date;

-- 2. Write a query to rank the products by total revenue within each store and filter out the top 3 best-selling products by revenue for each store.
WITH ProductRevenue AS (
    SELECT store_id, product_id, SUM(transaction_qty * unit_price) AS total_revenue,
	RANK() OVER (PARTITION BY store_id ORDER BY SUM(transaction_qty * unit_price) DESC) AS revenue_rank
    FROM coffee_shop_sales
    GROUP BY store_id, product_id)
SELECT store_id, product_id, total_revenue
FROM ProductRevenue
WHERE revenue_rank <= 3
ORDER BY store_id, revenue_rank;

-- 3. Identify all stores whose daily revenue exceeds the average revenue for that particular day.
WITH DailyRevenue AS (
    SELECT store_id, transaction_date, ROUND(SUM(transaction_qty * unit_price),2) AS daily_revenue
    FROM coffee_shop_sales
    GROUP BY store_id, transaction_date),
AvgDailyRevenue AS (
    SELECT transaction_date, AVG(daily_revenue) AS avg_revenue
    FROM DailyRevenue
    GROUP BY transaction_date)
SELECT dr.store_id, dr.transaction_date, dr.daily_revenue
FROM DailyRevenue dr
JOIN AvgDailyRevenue adr ON dr.transaction_date = adr.transaction_date
WHERE dr.daily_revenue > adr.avg_revenue
ORDER BY dr.transaction_date, dr.store_id;

-- 4. Identify the product category with the highest revenue across all stores.
SELECT product_category, ROUND(SUM(transaction_qty * unit_price),0) AS total_revenue
FROM coffee_shop_sales
GROUP BY product_category
ORDER BY total_revenue DESC
LIMIT 1;

-- 5. Write a query that calculates the total revenue by product category and store, and then ranks the stores by total revenue per category.
WITH CategoryRevenue AS (
    SELECT store_id, product_category, SUM(transaction_qty * unit_price) AS total_revenue
    FROM coffee_shop_sales
    GROUP BY store_id, product_category),
RankedStores AS (
    SELECT store_id, product_category, total_revenue,
        RANK() OVER (PARTITION BY product_category ORDER BY total_revenue DESC) AS revenue_rank
    FROM CategoryRevenue)
SELECT store_id, product_category, total_revenue, revenue_rank
FROM RankedStores
ORDER BY product_category, revenue_rank;

-- 6. Find the product with the highest total revenue for each store.
WITH ProductRevenue AS (
    SELECT 
        store_id,
        product_id, product_detail,
        SUM(transaction_qty * unit_price) AS total_revenue
    FROM coffee_shop_sales
    GROUP BY store_id, product_id, product_detail
)
SELECT 
    store_id,
    product_id, product_detail,
    total_revenue
FROM (
    SELECT 
        store_id,
        product_id, product_detail,
        total_revenue,
        RANK() OVER (PARTITION BY store_id ORDER BY total_revenue DESC) AS revenue_rank
    FROM ProductRevenue
) AS RankedProducts
WHERE revenue_rank = 1
ORDER BY store_id;

-- 7. Write a query to find the store with the highest average transaction value.
SELECT store_id, store_location, ROUND(AVG(transaction_qty * unit_price),2) AS avg_transaction_value
FROM coffee_shop_sales
GROUP BY store_id, store_location
ORDER BY avg_transaction_value DESC
LIMIT 1;

-- 8. Calculate the total revenue for each store and identify the store with the most varied product offerings.
SELECT store_id, store_location, ROUND(SUM(transaction_qty * unit_price),2) AS total_revenue, COUNT(DISTINCT product_id) AS distinct_products
FROM coffee_shop_sales
GROUP BY store_id, store_location
ORDER BY total_revenue DESC;


-- 9. Find the stores that have sold products from every category.
SELECT store_id, store_location
FROM coffee_shop_sales
GROUP BY store_id, store_location
HAVING COUNT(DISTINCT product_category) = (SELECT COUNT(DISTINCT product_category) FROM coffee_shop_sales);

-- 10. Find the total revenue for each product type, and then rank the product types by revenue.
WITH ProductTypeRevenue AS (
    SELECT product_type, ROUND(SUM(transaction_qty * unit_price),2) AS total_revenue
    FROM coffee_shop_sales
    GROUP BY product_type)
SELECT product_type, total_revenue, RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM ProductTypeRevenue
ORDER BY revenue_rank;

-- 11. Find the top 3 product categories with the highest average transaction value across all stores.
WITH CategoryAvgTransactionValue AS (
    SELECT product_category, ROUND(AVG(transaction_qty * unit_price),0) AS avg_transaction_value
    FROM coffee_shop_sales
    GROUP BY product_category)
SELECT product_category, avg_transaction_value
FROM CategoryAvgTransactionValue
ORDER BY avg_transaction_value DESC
LIMIT 3;

-- 12. Find the store with the highest number of products sold in a single transaction.
SELECT store_id, store_location, transaction_id, ROUND(SUM(transaction_qty),2) AS total_products_sold
FROM coffee_shop_sales
GROUP BY store_id, store_location, transaction_id
ORDER BY total_products_sold DESC
LIMIT 1;
