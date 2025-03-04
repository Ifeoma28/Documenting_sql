SELECT *
FROM sales;

SELECT *
FROM menu;

SELECT *
FROM members;

SELECT sales.customer_id,sales.order_date,menu.Product_name,menu.price
FROM sales
RIGHT JOIN menu ON
sales.Product_id = menu.Product_id
ORDER BY menu.price DESC
LIMIT 5;

-- The total amount each customer spent at the restaurant using the sales and menu table
SELECT sales.customer_id,sum(menu.price) AS total_price
 FROM sales 
 RIGHT JOIN menu ON
 sales.Product_id = menu.Product_id
 GROUP  BY sales.customer_id
 ORDER BY total_price DESC;
 
-- The no of days each customer visited the restaurant according to their customer id
 SELECT customer_id, COUNT(DISTINCT Order_date) AS no_of_days
 FROM sales
 GROUP BY customer_id;

-- First item from the menu purchased by each customer
SELECT customer_id,product_name AS first_purchased_product,rnk FROM 
(SELECT  sales.customer_id,menu.Product_name,
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rnk
FROM sales
JOIN menu ON
sales.Product_id = menu.Product_id) AS sales_rnk
WHERE rnk = 1
GROUP BY customer_id,product_name;
-- For customer A we have two products

-- Most purchased item on the menu
SELECT sales.Product_id, COUNT(*) AS Product_count,menu.product_name
FROM sales
INNER JOIN menu ON
sales.product_id = menu.product_id
GROUP BY Product_id,product_name
ORDER BY Product_count DESC
LIMIT 1;
 -- Ramen is the most purchased item and it was purchased 8 times

-- Most popular item for each customer
SELECT customer_id, sales.Product_id,COUNT(*) AS category_count,menu.product_name
FROM sales
LEFT JOIN menu ON sales.product_id = menu.product_id
GROUP BY Product_id,Customer_id,product_name
ORDER BY category_count DESC
;

-- creating a table from multiple tables, showing their member types
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

-- which item was purchased first by the customer after they become a member
SELECT customer_id,product_name AS first_purchased_product,rnk 
FROM 
	(SELECT  dannys.customer_id,dannys.Product_name,dannys.member_type,
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
	FROM dannys
	INNER JOIN members ON dannys.customer_id = members.customer_id
	WHERE member_type = 'Y' AND dannys.order_date > members.join_date) AS dannys_rnk
WHERE rnk = 1
GROUP BY customer_id,product_name;

-- which item was purchased first before they became a member
SELECT customer_id,product_name AS first_purchased_product,rnk 
FROM 
	(SELECT  dannys.customer_id,dannys.Product_name,dannys.member_type,
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
	FROM dannys
	INNER JOIN members ON dannys.customer_id = members.customer_id
	WHERE member_type = 'N' AND dannys.order_date < members.join_date) AS dannys_rnk
WHERE rnk = 1
GROUP BY customer_id,product_name;

SELECT *
FROM sales;


SELECT *
FROM DANNYS;

-- DROP TABLE DANNYS;

-- Total items and total amount spent for each member before they became a member
SELECT dannys.customer_id,COUNT(dannys.Product_name) AS Total_items,sum(dannys.price) AS Total_price
FROM DANNYS
INNER JOIN members ON
dannys.customer_id = members.customer_id
WHERE member_type = 'N' 
AND
order_date < join_date
GROUP BY customer_id;


-- ALTER TABLE DANNYS 
-- DROP points ;

-- ALTER TABLE DANNYS
-- DROP COLUMN Points ;

-- IF EACH $1 EQUATES TO 10 POINTS AND SUSHI HAS A 2X MULTIPLIER
-- WE WANT TO KNOW HOW MANY POINTS EACH CUSTOMER WOULD HAVE
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
    
-- In the first week after a customer joins the program(including their
-- join date) they earn 2* points on all items,not just sushi - how many points do customer 
-- A and B have at the end of January.
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
 
 -- Danny requires further information about the ranking of customer products
 -- but he dosent need the ranking for non-member purchases
 -- so he expects null ranking values for records when customers are not part of the program
SELECT customer_id,order_date,Product_name,price,member_type,
 IF (member_type = 'N', 'null',DENSE_RANK()  OVER(PARTITION BY customer_id,member_type ORDER BY member_type,price DESC,order_date )) AS ranking
FROM DANNYS;
 
    
