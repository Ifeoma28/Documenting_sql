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