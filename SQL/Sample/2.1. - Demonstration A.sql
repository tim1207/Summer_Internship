-- Demonstration A

--change database
USE TSQL2012;
GO

-- Step 2: Create the dbo.Orders table
CREATE TABLE dbo.Orders
( 
	OrderID int, 
	CustomerID int, 
	OrderDate date,
	Quantity int,
	Amount money
); 
GO 
CREATE CLUSTERED INDEX idx_Orders ON dbo.Orders
(OrderID);

-- Step 3: Inserting values into a table	
INSERT INTO dbo.Orders
VALUES(101,774,SYSDATETIME(),100,99.98),(102,775,SYSDATETIME(),32,49.99);

-- Step 4: Querying a table	
SELECT OrderID, CustomerID, OrderDate
FROM Sales.Orders;

-- Step 5: Querying a table	with expressions
SELECT OrderID, CustomerID, OrderDate, Quantity, Amount
	, (Quantity * Amount) as TotalAmount
FROM dbo.Orders;

-- Step 6: Querying a table	with a WHERE clause
SELECT OrderID, CustomerID, OrderDate, Quantity, Amount
FROM dbo.Orders
WHERE Quantity > 50;

-- Step 7: Querying a table	with a function in the WHERE clause
-- SYSDATETIME() 是系統function，使用 GetDate()也可以哦!
SELECT OrderID, CustomerID, OrderDate, Quantity, Amount
FROM dbo.Orders
WHERE OrderDate < GetDate(); --//SYSDATETIME()

-- Step 8: Querying a table	with a variable parameter 
DECLARE @CustomerID int = 775
SELECT OrderID, CustomerID, OrderDate, Quantity, Amount
FROM dbo.Orders
WHERE CustomerID = @CustomerID;


-- Cleanup task if needed.
-- 資料表dbo.Orders存在，就刪除它
IF OBJECT_ID('dbo.Orders') IS NOT NULL 
	DROP TABLE dbo.Orders;



--B
SELECT EmployeeID, YEAR(OrderDate) AS OrderYear, COUNT(1) as NumOrders
FROM Sales.Orders
GROUP BY EmployeeID,YEAR(OrderDate);

-- Step 2: Querying a table	 
-- 找出員工每年的訂單數，且訂單數大於1筆的資料
SELECT EmployeeID, YEAR(OrderDate) AS OrderYear, COUNT(*) as NumOrders
FROM Sales.Orders
WHERE CustomerID =71
GROUP BY EmployeeID,YEAR(OrderDate)
HAVING COUNT(*) > 1
ORDER BY EmployeeID, OrderYear;


-- Step 6: Querying a table	 
-- 以下才是正確的SQL
SELECT EmployeeID, YEAR(OrderDate) AS OrderYear, COUNT(*) as NumOrders
FROM Sales.Orders
WHERE CustomerID =71
GROUP BY EmployeeID,YEAR(OrderDate);

-- Step 7: Querying a table	 
-- 訂單大於一筆的資料，並不會依EmployeeID排序
SELECT EmployeeID, YEAR(OrderDate) AS OrderYear, COUNT(*) as NumOrders
FROM Sales.Orders
WHERE CustomerID =71
GROUP BY EmployeeID,YEAR(OrderDate)
HAVING COUNT(*) > 1;

-- Step 8: Querying a table	 
-- 要排序，要確切的使用Order By
SELECT EmployeeID, YEAR(OrderDate) AS OrderYear, COUNT(*) as NumOrders
FROM Sales.Orders
WHERE CustomerID =71
GROUP BY EmployeeID,YEAR(OrderDate)
HAVING COUNT(*) > 1
ORDER BY EmployeeID, NumOrders DESC;

