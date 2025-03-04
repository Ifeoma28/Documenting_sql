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
```
CREATE DATABASE pizza;
```


## Findings And Solutions 
