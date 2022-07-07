-- Demonstration A

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Simple SELECT query
-- 取得Sales.Shippers資料表ShipperID, CompanyName, Phone3個欄位的全部資料
SELECT ShipperID, CompanyName, Phone
FROM Sales.Shippers;
GO

-- Step 3: Simple SELECT query
-- 取得Sales.Shippers資料表所有欄位的全部資料
SELECT *
FROM Sales.Shippers;
GO

-- Step 6: Simple SELECT query with 計算的欄位
SELECT ProductID, ProductName, UnitPrice, (UnitPrice * 1.1)--AS p2
FROM Production.Products;

-- Step 7: Simple SELECT query with 計算的欄位
SELECT OrderID, ProductID, UnitPrice, Qty, (UnitPrice * Qty)
FROM Sales.OrderDetails;


-- Demonstration B

-- Step 1: 共有830筆資料，包含重覆的資料
SELECT CustomerID, ShipCity, ShipCountry
FROM Sales.Orders
ORDER BY CustomerID, ShipCity, ShipCountry;

-- Step 2: 加入 DISTINCT 來去除重覆的資料
SELECT DISTINCT CustomerID, ShipCity, ShipCountry
FROM Sales.Orders
ORDER BY CustomerID, ShipCity, ShipCountry;

-- Step 2: 欄位別名
SELECT EmployeeID as EmployeeID, FirstName as Given, LastName as Surname
FROM HR.Employees;

-- Step 3: 欄位別名
SELECT ProductID, ProductName, UnitPrice, (UnitPrice * 1.1) as MarkUP
FROM Production.Products;


-- Step 4: 欄位別名
SELECT EmployeeID, LastName as Surname, YEAR(HireDate) as YearHired
FROM HR.Employees;

-- Step 5: Table 別名，並用在欄位上面
SELECT SO.OrderID, SO.OrderDate, SO.EmployeeID
FROM Sales.Orders as SO;


-- Step 2: Simple CASE Expression
SELECT ProductID, ProductName, UnitPrice, 
	CASE Discontinued
		WHEN 0 THEN 'Active'
		WHEN 1 THEN 'Discontinued'
	END AS Status
FROM Production.Products;

-- Step 3: Simple CASE Expression
SELECT OrderID, CustomerID, OrderDate,
	CASE EmployeeID
		WHEN 1 THEN 'Buck'
		WHEN 2 THEN 'Cameron'
		WHEN 3 THEN 'Davis'
		WHEN 4 THEN 'Dolgopyatova'
		WHEN 5 THEN 'Funk'
		WHEN 6 THEN 'King'
		WHEN 7 THEN 'Lew'
		WHEN 8 THEN 'Peled'
		WHEN 9 THEN 'Suurs'
		ELSE 'Unknown Sales Rep'
	END AS SalesRep
FROM Sales.Orders;

 

-- Step 4:CASE 轉化要注意 DataType
SELECT OrderID, CustomerID, OrderDate,
	CASE EmployeeID
		WHEN 1 THEN 'Buck'
		WHEN 2 THEN 'Cameron'
		WHEN 3 THEN 'Davis'
		WHEN 4 THEN 'Dolgopyatova'
		WHEN 5 THEN  GETDATE()
		WHEN 6 THEN '2014/11/12'
		WHEN 7 THEN 'Lew'
		WHEN 8 THEN 'Peled'
		WHEN 9 THEN 'Suurs'
		ELSE 'Unknown Sales Rep'
	END AS SalesRep
FROM Sales.Orders;