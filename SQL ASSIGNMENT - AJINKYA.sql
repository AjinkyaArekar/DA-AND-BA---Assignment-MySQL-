
##Q1 -1 a.	Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employee number 1102 

SELECT DISTINCT jobtitle FROM employees;
SELECT DISTINCT employeeNumber, lastname, firstname
FROM employees
WHERE jobtitle = 'Sales Rep'
  AND reportsTo = 1102;

                                                    #--------#

###Q1 -2 Show the unique productline values containing the word cars at the end from the products table.


select productline
from productlines
where productline like "%cars";



### Q2 - CASE STATEMENTS for Segmentation

use classicmodels;
select CustomerNumber, CustomerName ,
case
when country in ("USA","Canada") then "North America"
when country in ("UK","France","Germany") then "Europe"
else "Other"
end as CustomerSegment
from customers;

                                             #--------#

###Q3 - Group By with Aggregation functions and Having clause, Date and Time functions

##A. a.	Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.

use classicmodels;
SHOW DATABASES;
SHOW TABLES;

SELECT productCode, SUM(quantityOrdered) AS total_order
FROM orderdetails
GROUP BY productCode
ORDER BY total_order DESC
LIMIT 10;

##B . 
select  monthname(paymentdate) as payment_month,
count(paymentDate) as num_payments from payments
group by 1
having num_payments > 20
order by num_payments desc;

                                             #--------#

#Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default

#A.
CREATE DATABASE Customers_Orders;

USE Customers_Orders;

CREATE TABLE Customers ( customer_id INT AUTO_INCREMENT PRIMARY KEY, 
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(255) UNIQUE,
phone_number VARCHAR(20));

show tables;

insert into customers (first_name,last_name,email,phone_number)
values ("Ajinkya","Arekar","arekarajinkya50@gmail.com",9930561832),
("Soham","Chavhan","sohamchavhan837@gmail.com",9930561832),
("Ishika","Kadam","ishikaaaaa6444@gmail.com",9930561832),
("VIDI","kadam","vidikadam6@57gmail.com",9930561832);
select * from customers;

                                                   #--------#

## B. b.	Create a table named Orders to store information about customer orders. Include the following columns:

create table orders(
order_id int auto_increment primary key,
customer_id int,
order_date date,
total_amount decimal (10,2),
check (total_amount>0),
foreign key (customer_id) references customers(customer_id));
desc orders;


INSERT INTO orders (customer_id, order_date, total_amount)
VALUES 
(1, '2025-11-12', 1500),
(2, '2025-10-22', 2500),
(4, '2025-07-01', 3500),
(1, '2025-09-04', 4500);

SELECT * FROM orders;

select * from customers
right join orders
on customers.customer_id = orders.customer_id;

                                             #--------#

# Q5. List the top 5 countries (by order count) that Classic Models ships to.

SELECT 
    c.country,
    COUNT(o.orderNumber) AS order_count
FROM 
    customers c
JOIN 
    orders o 
ON 
    c.customerNumber = o.customerNumber
GROUP BY 
    c.country
ORDER BY 
    order_count DESC
LIMIT 5;

                                #--------#
                                
# Q6. SELF JOIN

CREATE TABLE project (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    ManagerID INT);
INSERT INTO project (EmployeeID, FullName, Gender, ManagerID) VALUES
(1, 'Pranaya', 'Male', 3),
(2, 'Priyanka', 'Female', 1),
(3, 'Preety', 'Female', NULL),
(4, 'Anurag', 'Male', 1),
(5, 'Sambit', 'Male', 1),
(6, 'Rajesh', 'Male', 3),
(7, 'Hina', 'Female', 3);
SELECT 
    m.FullName AS 'Manager Name',
    e.FullName AS 'Emp Name'
FROM 
    project e
JOIN 
    project m ON e.ManagerID = m.EmployeeID
ORDER BY 1;

                                                      #--------#
                                                      
# Q7  DDL Commands: Create, Alter, Rename

# a) Create table

CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);

# i) Alter table — Add Primary Key and Auto Increment
ALTER TABLE facility
MODIFY Facility_ID INT AUTO_INCREMENT,
ADD PRIMARY KEY (Facility_ID);

# ii) Add new column City after Name (NOT NULL)
ALTER TABLE facility
ADD COLUMN City VARCHAR(100) NOT NULL AFTER Name;

                                      
                                                          #--------#
# Q8. Views in SQL   
         
CREATE VIEW product_category_sales AS
SELECT 
    p.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT od.orderNumber) AS number_of_orders
FROM 
    products p
JOIN 
    orderdetails od ON p.productCode = od.productCode
JOIN 
    orders o ON od.orderNumber = o.orderNumber
JOIN 
    productlines pl ON p.productLine = pl.productLine
GROUP BY 
    p.productLine
ORDER BY 
    total_sales DESC;

SELECT * FROM product_category_sales;

                                                  #--------#

#  Q9. Stored Procedures in SQL with parameters.

DELIMITER $$

CREATE PROCEDURE Get_country_payments(
    IN input_year INT,
    IN input_country VARCHAR(100)
)
BEGIN
    SELECT 
        YEAR(p.paymentDate) AS Year,
        c.country AS Country,
        CONCAT(ROUND(SUM(p.amount) / 1000), 'K') AS Total_Amount
    FROM 
        customers c
    JOIN 
        payments p ON c.customerNumber = p.customerNumber
    WHERE 
        YEAR(p.paymentDate) = input_year
        AND c.country = input_country
    GROUP BY 
        YEAR(p.paymentDate), c.country;
END $$

DELIMITER ;

CALL Get_country_payments(2003, 'France');


                                                       #--------#
                                                       
# Q10. Window functions - Rank, dense_rank, lead and lag.

SELECT 
    c.customerName,
    COUNT(o.orderNumber) AS Order_count,
    DENSE_RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rnk
FROM 
    customers c
JOIN 
    orders o 
ON 
    c.customerNumber = o.customerNumber
GROUP BY 
    c.customerName
ORDER BY 
    Order_count DESC;


# b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.

SELECT 
    Year,
    Month,
    Total_Orders,
    CONCAT(
        ROUND(
            (
                (Total_Orders - LAG(Total_Orders) OVER (PARTITION BY MonthNumber ORDER BY Year))
                / LAG(Total_Orders) OVER (PARTITION BY MonthNumber ORDER BY Year)
            ) * 100
        , 0),
        '%'
    ) AS `% YoY Change`
FROM (
    SELECT 
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS MonthNumber,
        MONTHNAME(OrderDate) AS Month,
        COUNT(*) AS Total_Orders
    FROM Orders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
) AS MonthlyOrders
ORDER BY Year, MonthNumber;

                                                         #--------#

# Q11.Subqueries and their applications

SELECT 
    productLine,
    COUNT(*) AS Total
FROM products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY productLine;

(SELECT AVG(buyPrice) FROM products)

                                                  #--------#
                                                  
# Q12. ERROR HANDLING in SQL

             
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);

DELIMITER $$

CREATE PROCEDURE InsertEmp_EH (
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
    -- Declare exit handler for any error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred' AS Message;
    END;

    -- Try to insert the record
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);

    -- If successful
    SELECT 'Record inserted successfully' AS Message;
END$$

DELIMITER ;


CALL InsertEmp_EH(1, 'John Doe', 'john.doe@example.com');


                                                         #--------#
                                                         

#Q13. TRIGGERS

CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);


INSERT INTO Emp_BIT VALUES ('John', 'Manager', '2020-10-05', -8);

SELECT * FROM Emp_BIT;




