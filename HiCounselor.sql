CREATE DATABASE hicounselor;

USE hicounselor;

CREATE TABLE Superstore(
Order_ID VARCHAR(50),
Order_Date DATE,
Ship_Date DATE,
Ship_Mode VARCHAR(50),	
Customer_ID VARCHAR(50),	
Customer_Name VARCHAR(50), 	
Segment VARCHAR(50), 
City VARCHAR(50),
State VARCHAR(50),	
Postal_Code VARCHAR(50),
Region VARCHAR(50),
Product_ID VARCHAR(50),
Category VARCHAR(50),
Sub_Category VARCHAR(50),
Product_Name VARCHAR(200),	
Sales DOUBLE
);

# DROP TABLE Superstore;

# SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Superstore_v2.csv"
INTO TABLE Superstore
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT * FROM superstore;

# (Task 1)What percentage of total orders were shipped on the same date?
SELECT ROUND(COUNT( DISTINCT CASE WHEN Ship_Date = Order_Date THEN Order_ID END)*100 / COUNT(DISTINCT Order_ID), 1) as Same_Day_Shipping_Percentage
FROM superstore;


# (Task 2)Name top 3 customers with highest total value of orders.
SELECT Customer_Name, ROUND(SUM(Sales), 4) AS TotalOrderValue
FROM superstore
GROUP BY Customer_Name
ORDER BY SUM(Sales) DESC
LIMIT 3;


# (Task 3)Find the top 5 items with the highest average sales per day.
SELECT Product_ID, AVG(Sales) AS HighestAverageSalePerDay
FROM superstore
GROUP BY Product_ID
ORDER BY 2 DESC
LIMIT 5;


# (Task 4)Write a query to find the average order value for each customer, and rank the customers by their average order value.
SELECT sub.Customer_ID, sub.Customer_Name, ROUND(AVG(sub.Total_Sales), 2) AS Avg_Order_Value
FROM(
SELECT Customer_ID, Customer_Name, SUM(Sales) AS Total_Sales
FROM superstore
GROUP BY Order_ID
ORDER BY 2 DESC) AS sub
GROUP BY 1, 2
ORDER BY 3 DESC;


# (Task 5)Give the name of customers who ordered highest and lowest orders from each city. -------
SELECT city, 
       MAX(sales) AS highest_order, 
       MIN(sales) AS lowest_order, 
       MAX(CASE WHEN sales = sales THEN customer_name ELSE NULL END) AS customer_with_highest_order, 
       MIN(CASE WHEN sales = sales THEN customer_name ELSE NULL END) AS customer_with_lowest_order
FROM superstore
GROUP BY city;


# (Task 6)What is the most demanded sub-category in the west region?
SELECT Sub_category, sum(sales) as total_quantity
FROM superstore
WHERE region = 'West'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


# (Task 7)Which order has the highest number of items? And which order has the highest cumulative value?
SELECT Order_ID, COUNT(Order_ID)
FROM superstore
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


# (Task 8)Which order has the highest cumulative value?
SELECT Order_ID, SUM(Sales) AS total_sales
fROM superstore
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


# (Task 9)Which segment’s order is more likely to be shipped via first class?
SELECT s.segment, COUNT(*) AS Segment_count 
FROM superstore s 
JOIN superstore s1 ON s.Order_ID = s1.Order_ID 
WHERE s1.ship_mode = 'First Class' 
GROUP BY s.segment 
ORDER BY 2 DESC 
LIMIT 1;


# (Task 10)Which city is least contributing to total revenue?
SELECT City,sum(Sales) 
FROM superstore 
GROUP BY City
ORDER BY sum(Sales) asc limit 1;


# (Task 11)What is the average time for orders to get shipped after order is placed?
SELECT CAST(AVG(sub.Avg_Day) AS DECIMAL(20, 8)) AS avg_ship_time
FROM(
SELECT DATEDIFF(Ship_Date, Order_Date) AS Avg_day
FROM superstore
GROUP BY Order_ID) AS sub;


# (Task 12)Which segment places the highest number of orders from each state and which segment places the largest individual orders from each state?--------
SELECT State, 
       (SELECT Segment
        FROM superstore t1
        WHERE t1.State = t.State
        GROUP BY Segment
        ORDER BY COUNT(Order_ID) DESC
        LIMIT 1) AS Segment_with_Highest_Orders,
       (SELECT Segment
        FROM superstore t2
        WHERE t2.State = t.State
        GROUP BY Segment
        ORDER BY MAX(Sales) DESC
        LIMIT 1) AS Segment_with_Largest_Individual_Order
FROM superstore t
GROUP BY State;


# (Task 13)Find all the customers who individually ordered on 3 consecutive days where each day’s total order was more than 50 in value. **--------
SELECT T.Customer_Name
FROM (SELECT T.*, COUNT(*) OVER(ORDER BY T.Order_Date 
RANGE BETWEEN INTERVAL 1 DAY PRECEDING 
AND INTERVAL 1 DAY FOLLOWING) cnt_days
FROM superstore T
WHERE T.Sales>50)T
WHERE T.cnt_days = 3;


# (Task 14)Find the maximum number of days for which total sales on each day kept rising.**-------
SELECT sub.Order_Date, sub.Curr_sale, sub.Next_sale,
CASE WHEN sub.Next_sale > sub.Curr_sale THEN RANK() OVER(  )
ELSE 0 END AS Rise_Days
FROM(
SELECT Order_Date, Sales AS Curr_sale,  LEAD(Sales) OVER(ORDER BY Order_Date) AS Next_sale
FROM superstore
GROUP BY 1
ORDER BY 1) AS sub
Order BY 1;


SELECT Order_Date,
CASE WHEN LEAD(Sales) OVER(ORDER BY Order_Date) > Sales THEN DENSE_RANK() OVER( PARTITION BY Order_Date)
ELSE 0 END AS Rise_Days
FROM superstore
GROUP BY 1
ORDER BY 1;

WITH cte as(
SELECT Order_Date,
CASE WHEN LEAD(Sales) OVER(ORDER BY Order_Date) > Sales THEN COUNT(Order_Date) OVER( PARTITION BY Order_Date)
ELSE 0 END AS Rise_Days
FROM superstore
GROUP BY 1
ORDER BY 1)
SELECT COUNT(c1.Rise_Days) AS Rising_Days
FROM 
cte c1, cte c2, cte c3
WHERE c1.Order_Date+1 = c2.Order_Date AND c1.Rise_Days = c2.Rise_Days AND 
c2.Order_Date+1 = c3.Order_Date AND c3.Rise_Days = c2.Rise_Days;

