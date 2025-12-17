use ecommerce_db;
# 1.Distribution and Summary Statistics
# 1.1 What is the total count of orders for each distinct Platform, and what percentage of the total order volume does each platform contribute?
SELECT
    platform,
    COUNT(*) AS orderCount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ecommerce), 2) AS PercentageOfTotal
FROM ecommerce
GROUP BY platform
ORDER BY orderCount DESC;

# 1.2 What are the Top 5 Product Category based on the total Order Value (INR)?
SELECT
	product_category,
    SUM(order_value) AS total_order_value
FROM ecommerce
GROUP BY product_category
ORDER BY total_order_value DESC
LIMIT 5;

#1.3 Determine the summary statistics (minimum, maximum, average) and the 25th, 50th (median), and 75th percentiles for the Order Value (INR).
WITH ordered AS (
    SELECT 
        order_value,
        ROW_NUMBER() OVER (ORDER BY order_value) AS rn,
        COUNT(*) OVER () AS total
    FROM ecommerce
)
SELECT
    MIN(order_value) AS MinValue,
    MAX(order_value) AS Max_Value,
    AVG(order_value) AS AverageValue,
    (SELECT order_value 
       FROM ordered 
       WHERE rn = FLOOR(0.25 * total)) AS Q1,
    (SELECT order_value 
       FROM ordered 
       WHERE rn = FLOOR(0.50 * total)) AS MedianValue,
    (SELECT order_value 
       FROM ordered 
       WHERE rn = FLOOR(0.75 * total)) AS Q3
FROM ordered;

# 2. Customer Experience and Service Quality
#2.1 Calculate the refund rate (percentage of orders with a 'Yes' Refund Requested) 
-- for each Platform to identify which platform has the highest customer dissatisfaction signal
SELECT
    platform,
    ROUND(CAST(SUM(CASE WHEN refund_requested = 'Yes' THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(*), 2) AS RefundRate
FROM ecommerce
GROUP BY 1
ORDER BY platform DESC;

-- 2.2 How many orders received a low rating (1 or 2), a neutral rating (3), and a high rating (4 or 5)?
SELECT
    CASE
        WHEN service_rating IN (1, 2) THEN 'Low (1-2)'
        WHEN service_rating = 3 THEN 'Neutral (3)'
        WHEN service_rating IN (4, 5) THEN 'High (4-5)'
        ELSE 'Other/Missing'
    END AS RatingGroup,
    COUNT(*) AS OrderCount
FROM ecommerce
GROUP BY 1;

-- 2.3 What is the average Service Rating for orders with a Delivery Delay ('Yes') compared to orders without a delay ('No')? 
SELECT
    delivery_delay,
    ROUND(AVG(service_rating),2) AS AverageRating,
    COUNT(*) AS TotalOrders
FROM ecommerce
GROUP BY delivery_delay
ORDER BY delivery_delay;

-- 3.Average Delivery Time by Product:
-- 3.1 What is the average Delivery Time (Minutes) for the top 5 most frequent Product Category?
SELECT
    t1.product_category,
    ROUND(AVG(t1.delivery_time_minutes),2) AS AverageDeliveryTime
FROM ecommerce AS t1
JOIN (
    SELECT product_category
    FROM ecommerce
    GROUP BY product_category
    ORDER BY COUNT(*) DESC
    LIMIT 5
) AS t2 ON t1.product_category = t2.product_category
GROUP BY product_category
ORDER BY AverageDeliveryTime DESC;

-- 3.2 Calculate the average Delivery Time (Minutes) for each Service Rating level (1 through 5) to see if longer times correlate with lower ratings?
SELECT
    service_rating,
    ROUND(AVG(delivery_time_minutes),2) AS AverageDeliveryTime
FROM ecommerce
GROUP BY service_rating
ORDER BY AverageDeliveryTime;

-- What are the top 5 most frequent phrases in the Customer Feedback column for orders where the Service Rating was 1 or 2?
SELECT
    customer_feedback,
    COUNT(*) AS feedbackCount
FROM ecommerce
WHERE service_rating IN (1, 2)
GROUP BY customer_feedback
ORDER BY feedbackcount DESC
LIMIT 5;

-- 3.4 Identify the count and characteristics (average Order Value, average Service Rating) of orders
--  with an extremely long delivery time (e.g., in the top 1% of Delivery Time (Minutes)). 
WITH p AS (
    SELECT 
        delivery_time_minutes,
        PERCENT_RANK() OVER (ORDER BY delivery_time_minutes) AS pr
    FROM ecommerce
)
SELECT
    COUNT(*) AS OutlierCount,
    AVG(order_value) AS AvgOrderValue,
    AVG(service_rating) AS AvgServiceRating
FROM ecommerce
WHERE delivery_time_minutes > (
        SELECT delivery_time_minutes 
        FROM p
        WHERE pr >= 0.99
        ORDER BY pr
        LIMIT 1
);

