-- Demonstration A

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Sorting by column name
SELECT OrderID, CustomerID, OrderDate
FROM Sales.Orders
ORDER BY CustomerID;

-- Step 3: Sorting by column alias name
SELECT OrderID, CustomerID, YEAR(OrderDate) AS OrderYear
FROM Sales.Orders
ORDER BY OrderYear DESC;

-- Step 4: Sorting by column name in descending order
SELECT OrderID, CustomerID, OrderDate
FROM Sales.Orders
ORDER BY OrderDate DESC;

-- Step 5: Changing sort order for multiple columns
SELECT HireDate, FirstName, LastName
FROM HR.Employees
ORDER BY HireDate DESC, LastName ASC;
--注意 HireDate 2003-10-17, LastName 依 asc 排列

-- Step 6: 隨機排序
SELECT HireDate, FirstName, LastName
FROM HR.Employees
ORDER BY NEWID();

SELECT HireDate, FirstName, LastName
FROM HR.Employees
ORDER BY  CHECKSUM(NEWID());

-- Demonstration B 
-- Filter

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: 找出2006年的訂單資料
SELECT OrderID, CustomerID, YEAR(OrderDate) AS OrdYear
FROM Sales.Orders
WHERE YEAR(OrderDate) = '2006'
ORDER BY OrderDate;


/*
5:Select
1:From
2:Where
3:Group
4:Having
6:Order By
*/
-- Step 3: Where不能用Select上的欄位別名 (順序問題)
SELECT OrderID, CustomerID, YEAR(OrderDate) AS OrdYear
FROM Sales.Orders
WHERE OrdYear = '2006';

---- Step 4: 找出在 西班牙 的客戶
SELECT ContactName, Country
FROM Sales.Customers
WHERE Country ='Spain';

-- Step 5: 找出訂單日期大於 2007年1月1日的訂單資料
SELECT OrderID, OrderDate
FROM Sales.Orders
WHERE OrderDate > '20070101';

--要小心日期的轉換
SELECT OrderID, OrderDate
FROM Sales.Orders
WHERE OrderDate > '2007-01-01 00:00:00上午';

-- Step 6: 找出在 香港或是在西班牙 的客戶
SELECT CustomerID, CompanyName, Country
FROM Sales.Customers
WHERE Country = 'UK' 
	OR Country = 'Spain';

-- Step 7:找出在 香港或是在西班牙 的客戶
SELECT CustomerID, CompanyName, Country
FROM Sales.Customers
WHERE Country IN (N'UK',N'Spain');

-- Step 8: 找出「不在」( 香港及西班牙) 的客戶
-- Use NOT operator with IN to provide an exclusion list
SELECT CustomerID, CompanyName, Country
FROM Sales.Customers
WHERE Country NOT IN (N'UK',N'Spain');

-- Step 9: Use WHERE to filter results
--取出2007年的資料
SELECT OrderID, CustomerID, OrderDate
FROM Sales.Orders
WHERE OrderDate > '2006/12/31' AND OrderDate < '2008-01-01';

-- Step 10: Use WHERE to filter results
-- Use BETWEEN operator to search within a range of dates
-- 包含2006/12/31 到 2008/1/1
SELECT OrderID, CustomerID, OrderDate
FROM Sales.Orders
WHERE OrderDate BETWEEN '20061231' AND '20080101';

SELECT OrderID, CustomerID, OrderDate
FROM Sales.Orders
WHERE OrderDate BETWEEN '20070101' AND '20071231';

-- Demonstration C 
-- TOP ****************************************************
--  Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Use TOP 5
SELECT TOP (5) OrderID, CustomerID, OrderDate
FROM Sales.Orders
ORDER BY OrderDate DESC;

-- Step 3: Use TOP to filter results
-- 在Top 5中的日期有2008-05-05及2008-05-06，所以這2個日期的資料全都出來
SELECT TOP (5) WITH TIES OrderID, CustomerID, OrderDate
FROM Sales.Orders
ORDER BY OrderDate DESC;

-- Step 4: Use TOP PERCENT 10%
SELECT TOP (10) PERCENT OrderID, CustomerID, OrderDate
FROM Sales.Orders
ORDER BY OrderDate DESC;

-- Step 5: 使用top但沒有order by
SELECT TOP (5) OrderID, CustomerID, OrderDate
FROM Sales.Orders;

-- Step 6: 強制用 Set ROWCOUNT 限制輸出筆數
Set ROWCOUNT 10;

SELECT OrderID, CustomerID, OrderDate
FROM Sales.Orders;


Set ROWCOUNT 0;

--  Demonstration D
-- NULL操作 *******************************************

--  Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

--  Step 2: Region including NULL
SELECT CustomerID, City, Region, Country
FROM Sales.Customers
ORDER BY Region;

--  Step 3: Handling NULLs
-- 不包含Region為NULL的資料
SELECT CustomerID, City, Region, Country
FROM Sales.Customers
WHERE Region <> N'SP';

--  Step 4:  Handling NULLs
-- This query also eliminates NULLs in Region
SELECT CustomerID, City, Region, Country
FROM Sales.Customers
WHERE Region = N'SP';

--  Step 5:  Handling NULLs
-- 可以用 = NULL 嗎? 
SET ANSI_NULLS ON; --預設是ON
SELECT CustomerID, City, Region, Country
FROM Sales.Customers
WHERE Region is NULL;

SET ANSI_NULLS OFF;
SELECT CustomerID, City, Region, Country
FROM Sales.Customers
WHERE Region = NULL;
SET ANSI_NULLS ON;

--  Step 6:  Handling NULLs
-- This query explicitly includes only NULLs
SELECT CustomerID, City, Region, Country
FROM Sales.Customers
WHERE Region IS NULL;

--  Step 7:  Handling NULLs
-- This query explicitly excludes NULLs
SELECT CustomerID, City, Region, Country
FROM Sales.Customers
WHERE Region IS NOT NULL;



/*
5:Select
1:From
2:Where
3:Group
4:Having
6:Order By
*/