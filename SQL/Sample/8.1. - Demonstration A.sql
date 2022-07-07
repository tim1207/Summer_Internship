--Table Expressions
-- Demonstration A
-- View *******************************
-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO


IF OBJECT_ID('HR.EmpPhoneList') IS NOT NULL
	DROP VIEW HR.EmpPhoneList;
GO


-- Step 2: Simple views
-- Select and execute the following to create a simple view
CREATE VIEW HR.EmpPhoneList
AS
SELECT EmployeeID, LastName, FirstName, Phone
FROM HR.Employees;
GO

-- Select from the new view
SELECT EmployeeID, LastName, FirstName, Phone
FROM HR.EmpPhoneList;
GO

IF OBJECT_ID('Sales.OrdersByEmployeeYear') IS NOT NULL
	DROP VIEW Sales.OrdersByEmployeeYear;
GO

-- Step 3: Complex views
-- Create a view using a multi-table join
CREATE VIEW Sales.OrdersByEmployeeYear
AS
    SELECT  Emp.EmployeeID AS Employee ,
            YEAR(ord.OrderDate) AS OrderYear ,
            SUM(od.Qty * od.UnitPrice) AS TotalSales
    FROM    HR.Employees AS Emp
            JOIN Sales.Orders AS ord ON Emp.EmployeeID = ord.EmployeeID
            JOIN Sales.OrderDetails AS od ON ord.OrderID = od.OrderID
    GROUP BY Emp.EmployeeID ,
            YEAR(ord.OrderDate)
GO
-- Select from the view
SELECT Employee, OrderYear, TotalSales
FROM Sales.OrdersByEmployeeYear
ORDER BY Employee, OrderYear;


-- Step 4: Clean up
IF OBJECT_ID('Sales.OrdersByEmployeeYear') IS NOT NULL
	DROP VIEW Sales.OrdersByEmployeeYear;
IF OBJECT_ID('HR.EmpPhoneList') IS NOT NULL
	DROP VIEW HR.EmpPhoneList;


-- Demonstration B
-- Inline Table-Valued Functions *************************

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Using functions
-- Note: dbo.GetNums() takes as parameters: @low (bigint) and (@high) bigint
SELECT * FROM dbo.GetNums(10,20);
GO

-- Step 3: Creating simple functions
-- Select and execute the following to 
-- Create a function to calculate line extension for Orders
CREATE FUNCTION Sales.fn_LineTotal ( @OrderID INT )
RETURNS TABLE
AS
RETURN
    SELECT  OrderID, ProductID, UnitPrice, Qty, Discount,
            CAST(( Qty * UnitPrice * ( 1 - Discount ) ) AS DECIMAL(8, 2)) AS LineTotal
    FROM    Sales.OrderDetails
    WHERE   OrderID = @OrderID ;
GO
-- Use the function
SELECT OrderID, ProductID, UnitPrice, Qty, Discount, LineTotal
FROM Sales.fn_LineTotal(10252) AS LT;
GO

-- Step 4: Cleanup
IF object_id('Sales.fn_LineTotal') IS NOT NULL
	DROP FUNCTION Sales.fn_LineTotal;
GO


-- Demonstration C
-- Using Derived Tables *******************************

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- 衍生資料表
SELECT OrderYear, COUNT(DISTINCT CustomerID) AS CustCount
FROM 
	(SELECT YEAR(OrderDate) AS OrderYear, CustomerID
	FROM Sales.Orders) AS DerivedYear
GROUP BY OrderYear;

-- 衍生資料表的欄位名稱，明確定義(不建議這樣用)
SELECT OrderYear_EX, COUNT(DISTINCT CustomerID_EX) AS CustCount
FROM 
	(SELECT YEAR(OrderDate), CustomerID
	FROM Sales.Orders) AS DerivedYear(OrderYear_EX, CustomerID_EX)
GROUP BY OrderYear_EX;

 
-- Nesting derived tables
SELECT OrderYear, CustCount
FROM  (
	SELECT  OrderYear, COUNT(DISTINCT CustomerID) AS CustCount
	FROM (
		SELECT YEAR(OrderDate) AS OrderYear ,CustomerID
        FROM Sales.Orders) AS DerivedTable1
	GROUP BY OrderYear) AS DerivedTable2
WHERE CustCount > 80;

-- Demonstration D
-- Common Table Expressions (CTE) ***********************************************

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO
-- Step 2: Common Table Expressions
-- -- Select this query and execute it to show CTE Examples
WITH CTEYear AS
	(
	SELECT YEAR(OrderDate) AS OrderYear, CustomerID
	FROM Sales.Orders
	)
SELECT OrderYear, COUNT(DISTINCT CustomerID) AS CustCount
FROM CTEYear
GROUP BY OrderYear;

-- 列出員工樹 recursive
WITH EmpOrg_CTE AS
(SELECT EmployeeID, [ManagerID], CAST(LastName + ' ' + FirstName AS NVARCHAR(80)) AS EmpName , 1 AS EmployeeLevel
	FROM HR.Employees
WHERE [ManagerID] IS null 
UNION ALL
SELECT Child.EmployeeID, Child.[ManagerID]
, CAST(REPLICATE ('|    ' , EmployeeLevel) + Child.LastName + ' ' + Child.FirstName AS NVARCHAR(80)) AS EmpName
, EmployeeLevel + 1
	FROM EmpOrg_CTE AS Parent
	JOIN HR.Employees AS Child
	ON Child.[ManagerID]=Parent.EmployeeID
)
SELECT EmployeeID, [ManagerID], EmpName, EmployeeLevel
FROM EmpOrg_CTE;


--多個CTE在一起
WITH MutiCTE1
AS (Select 1 as c1),
MutiCTE2 ( c1 )
AS ( Select 2) 
select * From MutiCTE1
union All
select * From MutiCTE2;

