# Danny's Diner

![17405939689274860221767329938625](https://github.com/user-attachments/assets/3980fcc7-c146-4349-b6b1-dd7ccf2c7c40)

## Overview 
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

### Objectives 
- Danny wants to use the data to answer a few simple questions, especially about their visiting patterns.
- He believes that having deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.
- He wants to know how much money they've spent and which menu food item is their favorite.
- He plans on using these insights to help him decide if he should continue the existing loyalty program.
- Also he needs help in generating a new dataset so his team can investigate the data without using sql.

## Dataset
The dataset for this project is sourced from [Danny Ma](https://www.linkedin.com/in/datawithdanny)

## Schema
```
-- create schema case_work;
USE case_work;
CREATE TABLE sales (
Customer_id VARCHAR(1),
Order_date DATE,
Product_id INTEGER
);

INSERT INTO sales
 (Customer_id,Order_date,Product_id)
VALUES
('A', '2021-01-01', '1'),
('A', '2021-01-01', '2'),
('A', '2021-01-07', '2'),
('A', '2021-01-10', '3'),
('A', '2021-01-11', '3'),
('A', '2021-01-11', '3'),
('B', '2021-01-01', '2'),
('B', '2021-01-02', '2'),
('B', '2021-01-04', '1'),
('B', '2021-01-11', '1'),
('B', '2021-01-16', '3'),
('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-07', '3');

CREATE TABLE menu (
Product_id INT,
Product_name VARCHAR(5),
price INT
);

INSERT INTO menu
(Product_id,Product_name,price)
VALUES
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');

CREATE TABLE members (
customer_id VARCHAR(1),
join_date DATE
);

INSERT INTO members
(customer_id,join_date)
VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

SELECT *
FROM sales;

SELECT *
FROM menu;

SELECT *
FROM members;
```

## Business Problems and Solutions 
- What is the total amount each customer spent at the restaurant ?
```
SELECT sales.customer_id,sum(menu.price) AS total_price
 FROM sales 
 RIGHT JOIN menu ON
 sales.Product_id = menu.Product_id
 GROUP  BY sales.customer_id
 ORDER BY total_price DESC;
```
- How many days has each customer visited the restaurant (according to customer ID) ?
 ```
 SELECT customer_id, COUNT(DISTINCT Order_date) AS no_of_days
 FROM sales
 GROUP BY customer_id;
 ```
- What was the first item from the menu purchased by each customer ?
```
SELECT customer_id,product_name AS first_purchased_product,rnk FROM 
(SELECT  sales.customer_id,menu.Product_name,
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rnk
FROM sales
JOIN menu ON
sales.Product_id = menu.Product_id) AS sales_rnk
WHERE rnk = 1
GROUP BY customer_id,product_name;
```
for customer A we have two food items.

- What is the most purchased item on the menu and how many times was it ?
```
SELECT sales.Product_id, COUNT(*) AS Product_count,menu.product_name
FROM sales
INNER JOIN menu ON
sales.product_id = menu.product_id
GROUP BY Product_id,product_name
ORDER BY Product_count DESC
LIMIT 1;
```
- Which item was the most popular for each customer ?
```
SELECT customer_id, sales.Product_id,COUNT(*) AS category_count,menu.product_name
FROM sales
LEFT JOIN menu ON sales.product_id = menu.product_id
GROUP BY Product_id,Customer_id,product_name
ORDER BY category_count DESC
;
```
- I created a table from multiple tables so the employees can easily access all the information of their customers, showing their member type.
```
CREATE TABLE DANNYS AS (
SELECT sales.Customer_id,sales.Order_date,menu.Product_name,menu.price,
 CASE 
	WHEN (sales.customer_id = 'A' AND datediff(members.join_date,sales.Order_date) <= 0 ) THEN 'Y'
	WHEN (sales.customer_id = 'A' AND datediff(members.join_date,sales.Order_date) > 0) THEN 'N'
	WHEN (sales.customer_id = 'B' AND datediff(members.join_date,sales.Order_date) <= 0) THEN 'Y'
	WHEN (sales.customer_id = 'B' AND datediff(members.join_date,sales.Order_date) > 0) THEN 'N'
	ELSE 'N'
    -- N means not a member, Y means a member
END AS member_type
FROM sales
LEFT JOIN menu ON
sales.Product_id = menu.Product_id
LEFT JOIN members ON
(sales.Product_id= menu.Product_id AND sales.Customer_id = members.customer_id)
);
```
- Which item was purchased first by the customer after they became a member ?
```
SELECT customer_id,product_name AS first_purchased_product,rnk 
FROM 
	(SELECT  dannys.customer_id,dannys.Product_name,dannys.member_type,
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
	FROM dannys
	INNER JOIN members ON dannys.customer_id = members.customer_id
	WHERE member_type = 'Y' AND dannys.order_date > members.join_date) AS dannys_rnk
WHERE rnk = 1
GROUP BY customer_id,product_name;
```
- Which item was purchased first just  before the customer became a member ?
```
SELECT customer_id,product_name AS first_purchased_product,rnk 
FROM 
	(SELECT  dannys.customer_id,dannys.Product_name,dannys.member_type,
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
	FROM dannys
	INNER JOIN members ON dannys.customer_id = members.customer_id
	WHERE member_type = 'N' AND dannys.order_date < members.join_date) AS dannys_rnk
WHERE rnk = 1
GROUP BY customer_id,product_name;
```
- What is the total items and amount spent for each member before they became a member ?
```
SELECT dannys.customer_id,COUNT(dannys.Product_name) AS Total_items,sum(dannys.price) AS Total_price
FROM DANNYS
INNER JOIN members ON
dannys.customer_id = members.customer_id
WHERE member_type = 'N' 
AND
order_date < join_date
GROUP BY customer_id;
```
- If each $1 spent equates to 10 points and sushi has a 2x points multiplier,how many points would each customer have ?
Therefore we calculate for points having the product name as sushi would be multiplying by 20 otherwise we multiply by 10
```
SELECT customer_id,SUM(points) AS total_points 
FROM
	(SELECT customer_id,Product_name,price,
		CASE 
			WHEN Product_name = 'sushi' THEN price * 20
			ELSE price * 10
		END AS points
	FROM DANNYS
    ORDER BY customer_id) AS 2_points_table
GROUP BY 1;
```
- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January ?
```
SELECT customer_id,SUM(price) AS total_price,SUM(points) AS total_points 
	FROM 
		(SELECT dannys.customer_id,dannys.Product_name,dannys.price,dannys.order_date,
		SUM(CASE 
			WHEN order_date BETWEEN members.join_date AND DATE_ADD(members.join_date,INTERVAL 6 DAY) THEN dannys.price*20
		ELSE 
			CASE WHEN dannys.product_name = 'sushi' THEN dannys.price * 20
			ELSE dannys.price * 10
            END
		END) AS points
	FROM dannys
    INNER JOIN members ON
    dannys.customer_id = members.customer_id
    WHERE order_date <= '2021-01-31' AND dannys.customer_id IN ('A','B')
    GROUP BY 1,2,3,4
	ORDER BY order_date 
    ) AS new_points_to_end_of_january 
GROUP BY customer_id;
```

## Findings And Solutions
- customer B visited the restaurant the most followed by customer A and then C
- Ramen is the most purchased food item and it was purchased 8 times
- customer spent more on food items more than customer A before they became a member
- customer C did not become a member due to the join date
- Every customer likes Ramen while only customer A and B likes sushi and adding extra points for Sushi shows only customer A and B would benefit
- After the customers join the loyalty program, I noticed customers tend to purchase Ramen and Sushi more than before joining the program.
- This shows that increasing the points customer accrue on purchasing Sushi would boost sales more because customers purchase of Sushi did not change after joining the program.
- Products that are least purchased should have higher points so customers would purchase them more.
- Danny could carry out surveys occassionally to know their customer preferences and also opinions on the overall taste of the food to help the restaurant keep up
