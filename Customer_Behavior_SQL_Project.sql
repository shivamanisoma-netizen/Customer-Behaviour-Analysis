
USE customer_behavior;
GO

-- Q1. Total revenue by male vs female
SELECT
    gender,
    SUM(purchase_amount) AS revenue
FROM customer
GROUP BY gender;


-- Q2. Customers who used discount but spent more than average
SELECT
    customer_id,
    purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
AND purchase_amount > (
    SELECT AVG(CAST(purchase_amount AS DECIMAL(10,2)))
    FROM customer
);


-- Q3. Top 5 products with highest average review rating
SELECT TOP 5
    item_purchased,
    CAST(ROUND(AVG(CAST(review_rating AS FLOAT)), 2)
        AS DECIMAL(10,2)) AS [Average Product Rating]
FROM customer
GROUP BY item_purchased
ORDER BY [Average Product Rating] DESC;


-- Q4. Average Purchase - Standard vs Express Shipping
SELECT
    shipping_type,
    CAST(AVG(CAST(purchase_amount AS DECIMAL(10,2)))
        AS DECIMAL(10,2)) AS avg_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;


-- Q5. Subscribers vs Non-subscribers
SELECT
    subscription_status,
    COUNT(customer_id) AS total_customers,
    CAST(AVG(CAST(purchase_amount AS DECIMAL(10,2)))
        AS DECIMAL(10,2)) AS avg_spend,
    CAST(ROUND(SUM(purchase_amount), 2)
        AS DECIMAL(10,2)) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;


-- Q6. Top 5 products with highest % discount purchases
SELECT TOP 5
    item_purchased,
    CAST(ROUND(
        100.0 * SUM(
            CASE
                WHEN discount_applied = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*), 2
    ) AS DECIMAL(10,2)) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC;


-- Q7. New / Returning / Loyal segmentation
;WITH customer_type AS (
    SELECT
        customer_id,
        previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)
SELECT
    customer_segment,
    COUNT(*) AS [Number of Customers]
FROM customer_type
GROUP BY customer_segment
ORDER BY [Number of Customers] DESC;


-- Q8. Top 3 most purchased products within each category
;WITH item_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT
    item_rank,
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3
ORDER BY category, item_rank;


-- Q9. Repeat buyers (>5 purchases) - do they subscribe?
SELECT
    subscription_status,
    COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;


-- Q10. Revenue contribution of each age group
SELECT
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;
