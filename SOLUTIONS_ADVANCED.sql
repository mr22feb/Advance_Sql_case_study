
-- 1. List all customers.
SELECT * FROM Customer

--2. List the first name, last name, and city of all customers
SELECT FirstName, LastName, City 
FROM Customer

-- 3. List the customers in Sweden. Remember it is "Sweden" and NOT "sweden" 
-- because filtering value is case sensitive in Redshift.
SELECT * FROM Customer
WHERE Country = 'SWEDEN'

-- 4. Create a copy of Supplier table. Update the city to Sydney for supplier 
-- starting with letter P.

SELECT
Id, CompanyName, ContactName, ContactTitle, Country,Phone,Fax,
CASE
		WHEN City like 'P%' 
				THEN 'Sydney' 
		ELSE City 
END AS [NEW_City] INTO SUPLLIER_COPY
FROM Supplier

SELECT * FROM SUPLLIER_COPY

-- 5. Create a copy of Products table and Delete all products with unit price 
-- higher than $50.

SELECT *  INTO PRODUCT_COPY
FROM Product

SELECT * FROM PRODUCT_COPY
DELETE FROM PRODUCT_COPY
WHERE UnitPrice > 50

-- 6. List the number of customers in each country.
SELECT 
Country, COUNT(ID) AS CUST_COUNT
FROM Customer
GROUP BY Country

-- 7. List the number of customers in each country sorted high to low.
SELECT 
Country, COUNT(ID) AS CUST_COUNT
FROM Customer
GROUP BY Country
ORDER BY CUST_COUNT DESC

-- 8. List the total amount for items ordered by each customer.
SELECT  CustomerId,
SUM(TotalAmount) AS TOT_AMT
FROM Orders
GROUP BY CustomerId

-- 9. List the number of customers in each country. Only include countries with 
-- more than 10 customers.
SELECT
COUNTRY, COUNT(ID) AS CUST_COUNT
FROM Customer
GROUP BY Country
HAVING COUNT(ID) > 10

-- 10. List the number of customers in each country, except the USA, sorted high 
-- to low. Only include countries with 9 or more customers.
SELECT
COUNTRY, COUNT(ID) AS CUST_COUNT
FROM Customer
WHERE Country <> 'USA'
GROUP BY Country
HAVING COUNT(ID) >= 9
ORDER BY CUST_COUNT DESC

-- 11. List all customers whose first name or last name contains "ill".
SELECT *
FROM Customer
WHERE FirstName LIKE '%ILL%'
			OR
	  LastName LIKE '%ILL%'

-- 12. List all customers whose average of their total order amount is between 
-- $1000 and $1200. Limit your output to 5 results.

SELECT 
CustomerId, AVG(TotalAmount) AS TOT_AMT
FROM Orders
GROUP BY CustomerId
HAVING AVG(TotalAmount) BETWEEN 1000 AND 1200

-- 13. List all suppliers in the 'USA', 'Japan', and 'Germany', ordered by country 
-- from A-Z, and then by company name in reverse order.
SELECT * 
FROM Supplier
WHERE Country IN ('USA', 'JAPAN', 'GERMANY')
ORDER BY Country ASC, CompanyName DESC

-- 14. Show all orders, sorted by total amount (the largest amount first), 
-- within each year.
SELECT 
YEAR(OrderDate) AS [YEAR],
TotalAmount 
FROM Orders
ORDER BY TotalAmount DESC

-- 15. Products with UnitPrice greater than 50 are not selling despite promotions. 
-- You are asked to discontinue products over $25. Write a query to relfelct this. 
-- Do this in the copy of the Product table. DO NOT perform the update operation in 
-- the Product table.
DELETE FROM PRODUCT_COPY
WHERE UnitPrice > 25
SELECT * FROM PRODUCT_COPY

-- 16. List top 10 most expensive products.
SELECT TOP 10 * 
FROM Product
ORDER BY UnitPrice DESC

-- 17. Get all, but the 10 most expensive products sorted by price.

-- USING OFFSET

SELECT * from Product
order by UnitPrice desc
OFFSET 10 ROWS

-- using ranks
SELECT * FROM (
		SELECT *,
		DENSE_RANK() OVER(ORDER BY UNITPRICE DESC) AS RANKS
		FROM Product
	) AS X
WHERE RANKS > 10


/* OFFSET can only be used with ORDER BY clause. It specifies the number of rows 
to skip before starting to return rows from the query. */

-- 18. Get the 10th to 15th most expensive products sorted by price.
-- METHOD 1:
SELECT * FROM (
				SELECT 
				ROW_NUMBER() OVER( ORDER BY UNITPRICE DESC ) AS [RANK], *
				FROM Product
			   ) AS T1
	WHERE RANK BETWEEN 10 AND 15

-- METHOD 2:
SELECT *  FROM Product
ORDER BY UnitPrice DESC
OFFSET 9 ROWS
FETCH NEXT 6 ROWS ONLY

-- 19. Write a query to get the number of supplier countries. Do not count 
-- duplicate values.

SELECT DISTINCT COUNT(Country) AS COUNTRY_COUNT
FROM Supplier

-- 20. Find the total sales cost in each month of the year 2013.
SELECT 
DATENAME(MONTH, OrderDate) AS MONTHS,
SUM(TotalAmount) AS TOT_AMT
FROM Orders
WHERE YEAR(OrderDate) = 2013
GROUP BY DATENAME(MONTH, OrderDate)

-- 21. List all products with names that start with 'Ca'.
SELECT * FROM Product
WHERE ProductName LIKE 'ca%'

-- 22. List all products that start with 'Cha' or 'Chan' and have 1 more character.
SELECT * FROM Product
WHERE ProductName LIKE 'CHA_'
			OR
	ProductName LIKE 'CHAN_'

-- 23. Your manager notices there are some suppliers without fax numbers. He seeks 
-- your help to get a list of suppliers with remark as "No fax number" for 
-- suppliers who do not have fax numbers (fax numbers might be null or blank).Also, 
-- Fax number should be displayed for customer with fax numbers.

SELECT 
Id, CompanyName, ContactName, ContactTitle, City, Country, Phone,
CASE
		WHEN Fax IS NULL OR LEN(FAX) = 0
				THEN 'No fax number'
		ELSE Fax
END AS [FAX INFO] 
FROM Supplier

-- USING UPDATE
UPDATE SUPPLIER_COPY SET Fax = 'NO FAX NUMBER'
WHERE Fax IS NULL OR LEN(FAX)= 0

-- 24. List all orders, their orderDates with product names, quantities, and 
-- prices.
SELECT 
T1.Id, OrderDate, ProductId, Quantity, UnitPrice
FROM Orders AS T1
INNER JOIN OrderItem AS T2
ON T1.Id = T2.OrderId

-- 25. List all customers who have not placed any Orders.
SELECT * 
FROM Customer AS A
LEFT JOIN Orders AS B
ON A.Id = B.CustomerId
WHERE B.Id IS NULL

-- 26. List suppliers that have no customers in their country, and customers that
-- have no suppliers in their country, and customers and suppliers that are 
-- from the same country.

SELECT 
CompanyName, S.Country, FIRSTNAME , LASTNAME, C.Country
FROM Supplier AS S
FULL OUTER JOIN Customer AS C
ON S.Country = C.Country
WHERE C.Id IS NULL

UNION ALL

SELECT 
CompanyName, S.Country, FIRSTNAME , LASTNAME,  C.Country
FROM Supplier AS S
FULL OUTER JOIN Customer AS C
ON S.Country = C.Country
WHERE S.Id IS NULL

UNION ALL 

SELECT 
CompanyName, S.Country, FIRSTNAME , LASTNAME, C.Country
FROM Supplier AS S
FULL OUTER JOIN Customer AS C
ON S.Country = C.Country
WHERE S.Country = C.Country

-- 27. Match customers that are from the same city and country. That is you are 
-- asked to give a list of customers that are from same country and city. Display 
-- firstname, lastname, city and country of such customers.

SELECT A.FirstName AS F_NAME1, A.LastName AS L_NAME1, B.FirstName AS F_NAME2,
B.LastName AS L_NAME2, A.City, A.Country
FROM CUSTOMER AS A
INNER JOIN CUSTOMER AS B
ON A.City = B.City
	AND
A.Country = B.Country
		AND
A.ID <> B.ID
WHERE A.Country = 'BRAZIL'
ORDER BY A.City, A.Country

-- 28. List all Suppliers and Customers. Give a Label in a separate column as 
-- 'Suppliers' if he is a supplier and 'Customer' if he is a customer accordingly. 
-- Also, do not display firstname and lastname as two fields; Display Full name 
-- of customer or supplier. 
SELECT 
CASE 
	WHEN [CONTACT NAME] IN (SELECT CONCAT(FIRSTNAME, ' ', LASTNAME) FROM Customer)
			THEN 'Customer'
	ELSE 'Supplier'
END AS [TYPE],
*
FROM (
		SELECT
		CONCAT(FIRSTNAME, ' ', LASTNAME) AS [CONTACT NAME],
		City, Country, Phone
		FROM Customer 
		
		UNION ALL
		
		SELECT
		CompanyName AS [CONTACT NAME],
		City, Country, Phone
		FROM Supplier
	) AS T1

-- 29. Create a copy of orders table. In this copy table, now add a column city of 
-- type varchar (40). Update this city column using the city info in customers 
-- table.

SELECT T1.*, T2.City INTO [ORDERS_COPY]
FROM Orders AS T1
LEFT JOIN Customer AS T2
ON T1.CustomerId = T2.Id

SELECT * FROM [ORDERS_COPY]

-- 30. Suppose you would like to see the last OrderID and the OrderDate for this last 
-- order that was shipped to 'Paris'. Along with that information, say you would also 
-- like to see the OrderDate for the last order shipped regardless of the Shipping City. 
-- In addition to this, you would also like to calculate the difference in days between 
-- these two OrderDates that you get. Write a single query which performs this. 
-- (Hint: make use of max (columnname) function to get the last order date and the output 
-- is a single row output.)
SELECT *,
DATEDIFF(DAY, [ LAST PARIS ORDER], [ LAST OVERALL ORDER] ) AS [ NUMBER OF DAYS]
FROM (
	SELECT ID, OrderDate  AS [ LAST PARIS ORDER],
	(SELECT MAX(OrderDate) FROM ORDERS_COPY) AS [ LAST OVERALL ORDER]
	FROM ORDERS_COPY
	WHERE City = 'PARIS' 
			AND 
	      OrderDate = (SELECT MAX(OrderDate) FROM ORDERS_COPY WHERE City = 'PARIS')
) AS X

-- OR
SELECT ID, OrderDate  AS [ LAST PARIS ORDER],
DATEDIFF( DAY, OrderDate, (SELECT MAX(OrderDate) FROM ORDERS_COPY) ) AS [DIFFERENCE]
	(SELECT MAX(OrderDate) FROM ORDERS_COPY) AS [ LAST OVERALL ORDER]
	FROM ORDERS_COPY
	WHERE City = 'PARIS' 
			AND 
	      OrderDate = (SELECT MAX(OrderDate) FROM ORDERS_COPY WHERE City = 'PARIS')

-- 31. Find those customer countries who do not have suppliers. This might help you 
-- provide better delivery time to customers by adding suppliers to these countires. 
-- HINT: Use SubQueries.

SELECT DISTINCT Country
FROM Customer 
WHERE Country NOT IN ( SELECT Country FROM Supplier )

-- USING JOINS
SELECT DISTINCT C.Country
FROM Customer C
FULL OUTER JOIN Supplier AS S
ON C.Country = S.Country
WHERE CompanyName IS NULL

-- 32. Suppose a company would like to do some targeted marketing where it would contact 
-- customers in the country with the fewest number of orders. It is hoped that this 
-- targeted marketing will increase the overall sales in the targeted country. You are 
-- asked to write a query to get all details of such customers from top 5 countries 
-- with fewest numbers of orders. Use Subqueries.

SELECT * FROM Customer
WHERE Country IN (
					SELECT TOP 5 Country
					FROM Customer AS C
					INNER JOIN Orders AS O
					ON C.Id = O.CustomerId
					GROUP BY Country
					ORDER BY COUNT(O.Id) ASC
				   )
-- 33. Let's say you want report of all distinct "OrderIDs" where the customer did not
-- purchase more than 10% of the average quantity sold for a given product. This way
-- you could review these orders, and possibly contact the customers, to help 
-- determine if there was a reason for the low quantity order. Write a query to report 
-- such orderIDs.
SELECT Distinct o.OrderId
from OrderItem o 
LEFT JOIN (
			 select ProductId, 
			 AVG( CAST(Quantity as float) ) AS [Average Qty for Prod] 
             from OrderItem GROUP BY ProductId
		   ) AS q1 
on o.ProductId = q1.ProductId
WHERE o.Quantity  < q1.[Average Qty for Prod] * 0.1

-- 34. Find Customers whose total orderitem amount is greater than 7500$ for the year 2013. The 
-- total order item amount for 1 order for a customer is calculated using the formula UnitPrice * 
-- Quantity * (1 - Discount). DO NOT consider the total amount column from 'Order' table to 
-- calculate the total orderItem for a customer.

SELECT CustomerId, CONCAT(FirstName, ' ', LastName) AS CUST_NAME,
SUM( UnitPrice * Quantity * (1 - Discount) ) AS TOT_ORD_ITEM_AMT 
FROM Customer AS C
INNER JOIN  Orders AS O
ON C.Id = O.CustomerId
INNER JOIN OrderItem AS OI
ON O.Id = OI.OrderId
WHERE YEAR(OrderDate) = 2013
GROUP BY CustomerId, CONCAT(FirstName, ' ', LastName)
HAVING SUM( UnitPrice * Quantity * (1 - Discount) ) > 7500

-- 35. Display the top two customers, based on the total dollar amount associated with their 
-- orders, per country. The dollar amount is calculated as OI.unitprice * OI.Quantity * (1 -
-- OI.Discount). You might want to perform a query like this so you can reward these customers, 
-- since they buy the most per country. 
-- Please note: if you receive the error message for this question "This type of correlated subquery 
-- pattern is not supported yet", that is totally fine.

SELECT * 
FROM ( 
		SELECT DENSE_RANK() OVER(PARTITION BY Country ORDER BY TOT_ORD_ITEM_AMT DESC) AS RANKS, *
		FROM (
				SELECT CustomerId, CONCAT(FirstName, ' ', LastName) AS CUST_NAME, C.Country,
				SUM( UnitPrice * Quantity * (1 - Discount) ) AS TOT_ORD_ITEM_AMT
				FROM Customer AS C
				INNER JOIN  Orders AS O
				ON C.Id = O.CustomerId
				INNER JOIN OrderItem AS OI
				ON O.Id = OI.OrderId
				GROUP BY CustomerId, CONCAT(FirstName, ' ', LastName), C.Country
			) AS X
	) AS FINAL
WHERE RANKS <= 2

-- 36. Create a View of Products whose unit price is above average Price.

CREATE VIEW PROD_PRICE_ABOVE_AVERAGE
AS
	SELECT * FROM Product
	WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Product)
		
SELECT * FROM PROD_PRICE_ABOVE_AVERAGE

-- 37. Write a store procedure that performs the following action:
-- Check if Product_copy table (this is a copy of Product table) is present. If table exists, the 
-- procedure should drop this table first and recreated.
-- Add a column Supplier_name in this copy table. Update this column with that of 
-- 'CompanyName' column from Supplier table.

CREATE PROCEDURE Q37
AS
	if 'PRODUCT_COPY' IN (select TABLE_NAME from  INFORMATION_SCHEMA.TABLES)
	begin 
		drop TABLE PRODUCT_COPY
		select p.*, s.CompanyName into PRODUCT_COPY2
		from Product p 
		LEFT JOIN Supplier s 
		on p.SupplierId = s.Id 
	END

EXEC Q37

SELECT * FROM PRODUCT_COPY2


