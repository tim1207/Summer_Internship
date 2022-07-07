-- Demonstration A

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Using built-in Aggregate functions
--全部的平均及最大數量及最大的折扣
SELECT AVG(UnitPrice) AS AvgPrice, MIN(Qty)AS MinPrice, MAX(Discount) AS MaxDiscount
FROM Sales.OrderDetails;

-- 不只是數值，字串、日期也都可使用彙總函數
SELECT MIN(CompanyName) AS FirstCustomer, MAX(CompanyName) AS LastCustomer
FROM Sales.Customers;

-- The use of aggregates with non-numeric data types:
SELECT MIN(OrderDate)AS Earliest,MAX(OrderDate) AS Latest
FROM Sales.Orders;


--如果使用 欄位+彙總Fun ，但沒有Group的話，會掛給你看
SELECT OrderID, ProductID, AVG(UnitPrice) , MAX(Qty) , MAX(Discount) 
FROM Sales.OrderDetails
--GROUP BY OrderID, ProductID;


-- 使用 DISTINCT with aggregate functions:
SELECT EmployeeID, YEAR(OrderDate) AS OrderYear,
COUNT(CustomerID) AS AllCusts,
COUNT(DISTINCT CustomerID) AS UniqueCusts
FROM Sales.Orders
GROUP BY EmployeeID, YEAR(OrderDate);

-- Select and execute the following query to show
-- the impact of NULL on aggregate functions
-- First, show the existence of NULLs in Sales.Orders
SELECT ShippedDate
FROM Sales.Orders
WHERE ShippedDate IS NOT NULL
ORDER BY ShippedDate;

SELECT ShippedDate
FROM Sales.Orders
ORDER BY ShippedDate;

-- Then show that MIN, MAX and COUNT ignore NULL, COUNT(*) doesn't.
-- Show the messages tab in the SSMS results pane (警告: 彙總或其他 SET 作業已刪除 Null 值。)
SELECT MIN(ShippedDate) AS Earliest, MAX(ShippedDate) AS Latest
, COUNT(ShippedDate) AS [CountShippedDate], COUNT(*) AS CountAll
FROM Sales.Orders;

-- Step 3: 以下測試 NULL 在彙總函數上的使用

-- Create an example table
CREATE TABLE dbo.t1(
	c1 INT IDENTITY NOT NULL PRIMARY KEY,
	c2 INT NULL);
-- Populate it	
INSERT INTO dbo.t1(c2)
VALUES(NULL),(10),(20),(30),(40),(50);
-- View the contents. Note the NULL
SELECT c1, c2 FROM dbo.t1;

-- Run完後，切到訊息的Tab看警告訊息
SELECT SUM(c2) AS SumNonnulls
, COUNT(*) AS CountAllRows
, COUNT(c2)AS CountNonnulls
, AVG(c2) AS [Avg] --除了Count(*) 其他的不會管 NULL，150 / 5
, (SUM(c2)/COUNT(*)) AS ArithAvg
FROM dbo.t1;
--可以打消炎藥 SET ANSI_WARNINGS OFF


-- 可透過 COALESCE or ISNULL 來處理Null值
SELECT SUM(COALESCE(c2,0)) AS SumNonnulls
, COUNT(*) AS CountAllRows
, COUNT(COALESCE(c2,0))AS CountNonnulls
, AVG(COALESCE(c2,0)) AS [Avg]
, (SUM(COALESCE(c2,0))/COUNT(*))AS ArithAvg
FROM dbo.t1;
 
SELECT SUM(ISNULL(c2,0)) AS SumNonnulls
, COUNT(*) AS CountAllRows
, COUNT(ISNULL(c2,0))AS CountNonnulls
, AVG(ISNULL(c2,0)) AS [Avg]
, (SUM(ISNULL(c2,0))/COUNT(*))AS ArithAvg
FROM dbo.t1;

-- clean up
IF OBJECT_ID('dbo.t1') IS NOT NULL 
	DROP TABLE dbo.t1;
 
 
-- Demonstration B
-- GROUP BY ..........................

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Using GROUP BY
-- 依最多Order的EmployeeID排序
SELECT EmployeeID, COUNT(*) AS CNT
FROM Sales.Orders
GROUP BY EmployeeID
ORDER BY CNT desc;

-- show 員工id4的客戶每年的訂單數
SELECT CustomerID, YEAR(OrderDate) AS [year], COUNT(*) AS CNT
FROM Sales.Orders
WHERE EmployeeID = 4
GROUP BY CustomerID, YEAR(OrderDate);

 
-- 每個客戶的訂單數
SELECT CustomerID, COUNT(*) AS CNT
FROM Sales.Orders
GROUP BY CustomerID;

-- 每個產品最大的訂單數量
SELECT ProductID, MAX(Qty) AS LargestOrder
FROM Sales.OrderDetails
GROUP BY ProductID;


-- Demonstration C
-- Group Having *********************************

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Using the HAVING clause
-- 找出訂單數10筆以上的客戶
SELECT CustomerID, COUNT(*) AS CountOrders
FROM Sales.Orders
GROUP BY CustomerID
HAVING COUNT(*) >= 10
ORDER BY CountOrders;

-- THIS WILL FAIL (只有Order By才能用Select的別名)
SELECT CustomerID, COUNT(*) AS CountOrders
FROM Sales.Orders
GROUP BY CustomerID
HAVING CountOrders >= 10;

-- 找出平均數量大於20的產品分類
SELECT p.CategoryID, COUNT(*) AS CNT, AVG(Qty) AS [AvgQty]
FROM Production.Products AS p
JOIN Sales.OrderDetails AS od
	ON p.ProductID = od.ProductID
GROUP BY p.CategoryID
HAVING AVG(Qty) > 20;

-- 找出訂單數超過1筆的客戶
SELECT c.CustomerID, COUNT(*) AS CNT
FROM Sales.Customers AS c
JOIN Sales.Orders AS o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
HAVING COUNT(*) > 1
ORDER BY CNT DESC;

--找出產品被訂購超過9筆的資料
SELECT p.ProductID, COUNT(*) AS CNT
FROM Production.Products AS p
JOIN Sales.OrderDetails AS od
ON p.ProductID = od.ProductID
GROUP BY p.ProductID
HAVING COUNT(*) >= 10
ORDER BY CNT DESC;

/*
5:Select
1:From
2:Where
3:Group
4:Having
6:Order By
*/