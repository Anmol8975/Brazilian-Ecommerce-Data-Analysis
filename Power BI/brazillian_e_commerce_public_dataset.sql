--  Create DATABASE brazilian_e_commerce_public_dataset--
CREATE DATABASE brazilian_e_commerce_public_dataset

--  Create customer table 
CREATE TABLE customer(
customer_id	 "varchar"(100) PRIMARY key ,
customer_city VARCHAR(60),
customer_state "varchar"(10)
)

-- Now import data to customer table 

SELECT *
from customer

-- create product table     
CREATE TABLE product(
product_id "varchar"(100) PRIMARY key,
product_category VARCHAR (50)
)

-- import data to product table 
SELECT *
from product

-- create sellers table     
CREATE TABLE seller(
seller_id "varchar"(100) PRIMARY key ,
seller_city VARCHAR(50),
seller_state "varchar"(10)
)

-- import data to seller table 
SELECT *
from seller

-- create order table 
CREATE TABLE orders(
order_id varchar(60) PRIMARY key,
customer_id VARCHAR(60),
order_status varchar(30),
order_purchase_timestamp timestamp,
order_delivered_carrier_date timestamp,
order_delivered_customer_date timestamp,
foreign key (customer_id) REFERENCES customer (customer_id)
)

-- import data to orders table 

SELECT *
from orders

-- create order_items table 
CREATE TABLE order_items (
order_id varchar(60),
product_id varchar(60),
seller_id varchar(60),
price decimal(10,2),
foreign key (order_id) REFERENCES orders (order_id),
foreign key (product_id) REFERENCES product (product_id),
foreign key (seller_id) REFERENCES seller (seller_id)
)

-- import data to order_items table 
SELECT *
from order_items

-- create payments table 
CREATE TABLE payments(
order_id varchar(60),
payment_type varchar(20),
payment_value decimal(10,2),
foreign key (order_id) REFERENCES orders (order_id)
)

-- import dat to payments table 
SELECT *
from payments

-- create reviews table 
CREATE TABLE reviews(
order_id varchar(60),
review_score int,
foreign key (order_id) REFERENCES orders (order_id)
)

-- import data to reviews table 
SELECT *
from reviews

-- most popular payment methods
SELECT  payment_type ,count(*) as payment_count
from payments
group by payment_type


-- top 5 category that generated the highest revenue
SELECT product_category , sum(price) AS total_revenue
from product AS p
JOIN order_items AS o
ON o.product_id = p.product_id
GROUP by product_category
ORDER by total_revenue DESC
LIMIT 5 

-- top 5 cities that have most customer
SELECT customer_city , count(*) AS total_customer
from customer
group by customer_city
ORDER by total_customer desc
LIMIT 5 

-- IDENTITY top 10 sellers by order and their avg_review-score
SELECT seller_id , round (avg(review_score),2) AS avg_review_score , count(o.order_id) as total_orders
FROM order_items as o
JOIN reviews as r
ON o.order_id = r.order_id
GROUP by seller_id
ORDER by  total_orders DESC
LIMIT 10

-- top 10 highest sales by customer_state
SELECT customer_state , sum(price) AS total_revenue 
from customer as c
JOIN orders as o
on c.customer_id = o.customer_id
JOIN order_items as ot
on o.order_id = ot.order_id
GROUP by customer_state
ORDER by total_revenue DESC
LIMIT 10

-- Is there a correlation between delivery time and review score? 
SELECT  review_score , avg ( order_delivered_customer_date:: date - order_purchase_timestamp:: date) , count(o.order_id)
FROM reviews as r
join orders as o
ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date is not null
GROUP by review_score

-- how many orders were placed and what are their order_status
SELECT order_status , count(*)
FROM orders 
group by order_status

-- total revenue by MONTH in 2018   
SELECT 
    EXTRACT(month FROM order_purchase_timestamp) AS month_num,
    TO_CHAR(order_purchase_timestamp, 'Month') AS month_name,
    SUM(payment_value) AS total_revenue
FROM orders
JOIN payments 
    ON orders.order_id = payments.order_id
WHERE order_purchase_timestamp >= '2018-01-01' 
  AND order_purchase_timestamp <= '2018-12-31'
GROUP BY month_num, month_name
ORDER BY month_num


