-- Retrieve the total number of orders placed.
select count(order_id) as total from orders;


-- Calculate the total revenue generated from pizza sales.
select round(sum(p.price * o.quantity),2) as total_sales
from pizzas p
inner join orders_details o on p.pizza_id = o.pizza_id;
 
 
 -- Identify the highest-priced pizza.
select pt.name, p.price
from pizzas p
inner join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
order by p.price desc
limit 1;


-- Identify the most common pizza size ordered.
select p.size, count(o.order_details_id) as order_count
from pizzas p
inner join orders_details o on p.pizza_id = o.pizza_id
group by p.size
order by order_count desc;


-- List the top 5 most ordered pizza types along with their quantities.
select pt.name, sum(o.quantity) as quantity
from pizza_types pt
inner join pizzas p on pt.pizza_type_id = p.pizza_type_id
inner join orders_details o on p.pizza_id = o.pizza_id
group by pt.name
order by quantity desc
limit 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category, sum(o.quantity) as quantity
from pizza_types pt
inner join pizzas p on pt.pizza_type_id = p.pizza_type_id
inner join orders_details o on p.pizza_id = o.pizza_id
group by pt.category
order by quantity;


-- Determine the distribution of orders by hour of the day.
select hour(order_time) as hour, count(order_id)
from orders
group by hour;


-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name)
from pizza_types
group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) from
(select o.order_date, sum(od.quantity) as quantity
from orders o
inner join orders_details od on o.order_id= od.order_id
group by order_date) as order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.
select pt.name, sum(p.price * o.quantity) as revenue
from pizza_types pt
inner join pizzas p on pt.pizza_type_id = p.pizza_type_id
inner join orders_details o on p.pizza_id = o.pizza_id
group by pt.name
order by revenue desc
limit 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
select pt.category, round((sum(p.price * o.quantity) / (select round(sum(p.price * o.quantity),2) as total_sales
from pizzas p
inner join orders_details o on p.pizza_id = o.pizza_id) )*100,2) as revenue
from pizza_types pt
inner join pizzas p on pt.pizza_type_id = p.pizza_type_id
inner join orders_details o on p.pizza_id = o.pizza_id
group by pt.category
order by revenue desc;


-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select o.order_date, sum(od.quantity* p.price) as revenue
from orders_details od
inner join pizzas p on od.pizza_id = p.pizza_id
inner join orders o on od.order_id = o.order_id
group by o.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue,
rank() over(partition by category order by revenue desc) as ran
from
(select pt.category, pt.name,
sum(od.quantity * p.price) as revenue
from pizza_types pt
inner join pizzas p on pt.pizza_type_id = p.pizza_type_id
inner join orders_details od on p.pizza_id = od.pizza_id
group by pt.category, pt.name) as a;