create database pizza;
drop database pizza;
use  pizza;
-- Retrieve the total number of orders placed.

select count(*) as total_order from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT SUM(price) AS total_revenue
FROM pizzas;

-- Identify the highest-priced pizza.


select price as highest_price from pizzas order by  price DESC limit 1;


-- Identify the most common pizza size ordered.

SELECT 
    size, COUNT(*) AS order_count
FROM
    pizzas
GROUP BY size
ORDER BY order_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5; 

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id) as order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
 
--  Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_qunatity;
    
--   Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price)) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

(SELECT 
    pizza_types.category,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue);

-- Analyze the cumulative revenue generated over time.
select date , 
sum(revenue) over (order by date) as cum_revenue
from
(SELECT 
    orders.date,
    sum(pizzas.price * order_details.quantity) AS revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
group by orders.date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    category, 
    name, 
    revenue,
    rn
FROM
    (SELECT 
        pt.category, 
        pt.name,  
        SUM(p.price * od.quantity) AS revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(p.price * od.quantity) DESC) AS rn
    FROM
        pizza_types pt
    JOIN
        pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN
        order_details od ON od.pizza_id = p.pizza_id
    GROUP BY 
        pt.category, pt.name
    ) ranked_pizzas
WHERE rn <= 3;









