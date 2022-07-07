-- Demonstration A
-- Union, Union ALL

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Using UNION ALL
SELECT Country, Region, City FROM HR.Employees
UNION ALL -- 100 rows
SELECT Country, Region, City FROM Sales.Customers;

-- Step 3: Using UNION
SELECT Country, Region, City FROM HR.Employees 
UNION 
SELECT Country, Region, City FROM Sales.Customers; 

-- Step 2: Using INTERSECT 交集
SELECT Country, Region, City FROM HR.Employees
INTERSECT -- 3 distinct rows 
SELECT Country, Region, City FROM Sales.Customers;

-- Step 3: Using EXCEPT 注意 Left or Right
-- Return only rows from left table (Hr.Employees)
SELECT Country, Region, City FROM HR.Employees
EXCEPT 
SELECT Country, Region, City FROM Sales.Customers;

--Reverse position of tables, return only rows from Sales.Customers
SELECT Country, Region, City FROM Sales.Customers
EXCEPT 
SELECT Country, Region, City FROM HR.Employees;


-- Demonstration C
-- Apply ***************************************

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

IF OBJECT_ID('dbo.fn_SalesOrdersDate') IS NOT NULL
	DROP FUNCTION dbo.fn_SalesOrdersDate;
GO

-- 建立依客戶代號，取回最近的3筆資料 OrderID, OrderDate
CREATE  FUNCTION dbo.fn_SalesOrdersDate
(@CustomerID int)
RETURNS TABLE
AS
RETURN
	SELECT TOP (3) OrderID, OrderDate
	FROM Sales.Orders AS O
	WHERE O.CustomerID = @CustomerID
	ORDER BY OrderDate DESC, OrderID DESC;
GO

-- Step 3: Test the function
SELECT * FROM dbo.fn_SalesOrdersDate(2);

-- CROSS APPLY with function
-- 對不到資料，就不傳回資料，如CustomerID 99, 106
SELECT C.CustomerID, C.CompanyName, O.OrderID, O.OrderDate
from Sales.Customers as C
CROSS APPLY dbo.fn_SalesOrdersDate(C.CustomerID) AS O
ORDER BY C.CustomerID;

-- 把function 用 衍生資料表 代替
SELECT C.CustomerID, C.CompanyName, O.OrderID, O.OrderDate 
from Sales.Customers as C
CROSS APPLY (SELECT TOP (3) OrderID, OrderDate
	FROM Sales.Orders AS ord
	WHERE ord.CustomerID = C.CustomerID
	ORDER BY OrderDate DESC, OrderID DESC) AS O
ORDER BY C.CustomerID;

 

-- Step 4: Using OUTER APPLY
-- 會加上NULL的資料
SELECT C.CustomerID, C.CompanyName, O.OrderID, O.OrderDate 
from Sales.Customers as C
OUTER APPLY dbo.fn_SalesOrdersDate(C.CustomerID) AS O
ORDER BY C.CustomerID;

-- with 衍生資料表
SELECT C.CustomerID, C.CompanyName, O.OrderID, O.OrderDate 
from Sales.Customers as C
OUTER APPLY (SELECT TOP (3) OrderID, OrderDate
	FROM Sales.Orders AS ord
	WHERE ord.CustomerID = C.CustomerID
	ORDER BY OrderDate DESC, OrderID DESC) AS O
ORDER BY C.CustomerID;

--clean up
IF OBJECT_ID('dbo.fn_SalesOrdersDate') IS NOT NULL
	DROP FUNCTION dbo.fn_SalesOrdersDate;