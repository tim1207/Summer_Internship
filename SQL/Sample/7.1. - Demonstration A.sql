-- Demonstration A
-- SubQuery 通常用在Where

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO
-- 找出OrderID最大的訂單資料
SELECT OrderID, ProductID, UnitPrice, Qty
FROM Sales.OrderDetails
WHERE OrderID = 
	(SELECT MAX(OrderID) AS LastOrder
	FROM Sales.Orders);

-- THIS WILL FAIL, since
-- 1 value 子查詢傳回不只 1 個值。這種狀況在子查詢之後有 =、!=、<、<=、>、>= 或是子查詢做為運算式使用時是不允許的。
SELECT OrderID, ProductID, UnitPrice, Qty
FROM Sales.OrderDetails
WHERE OrderID = 
	(SELECT OrderID AS O
	FROM Sales.Orders
	WHERE EmployeeID =2);

-- Step 3: 使用IN
SELECT CustomerID, OrderID
FROM Sales.Orders
WHERE CustomerID IN (
	SELECT CustomerID
	FROM Sales.Customers
	WHERE Country = N'Mexico');

-- 用Join也可達到相同的效果
SELECT c.CustomerID, o.OrderID
FROM Sales.Customers AS c JOIN Sales.Orders AS o
ON c.CustomerID = o.CustomerID
WHERE c.Country = N'Mexico';


--  Demonstration B
--  Correlated Subqueries *******************************
--  Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Correlated subqueries
-- 找出每個客戶最近的訂單資料
SELECT CustomerID, OrderID, OrderDate
FROM Sales.Orders AS OuterOrders
WHERE OrderDate =
	(SELECT MAX(OrderDate)
	FROM Sales.Orders AS InnerOrders
	WHERE InnerOrders.CustomerID = OuterOrders.CustomerID)
ORDER BY CustomerID;

-- 找出每個員工最近的接到的訂單資料
SELECT EmployeeID, OrderID, OrderDate
FROM Sales.Orders AS O1
WHERE OrderDate =
	(SELECT MAX(OrderDate)
	 FROM Sales.Orders AS O2
	 WHERE O2.EmployeeID = O1.EmployeeID)
ORDER BY EmployeeID, OrderDate;

-- 找出每個客戶最大訂單數量最大的訂單資料
--SELECT * FROM Sales.CustOrders WHERE CustomerID = 1;

SELECT CustomerID, OrderMonth, Qty
FROM Sales.CustOrders AS OuterCustOrders
WHERE Qty =
	(SELECT MAX(Qty)
		FROM Sales.CustOrders AS InnerCustOrders
		WHERE InnerCustOrders.CustomerID =OuterCustOrders.CustomerID
	)
ORDER BY CustomerID;

--  Demonstration C
-- Working with EXISTS ***********************************
--  Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- 找出 有 訂單的客戶
SELECT CustomerID, CompanyName
FROM Sales.Customers AS c
WHERE EXISTS (
	SELECT * 
	FROM Sales.Orders AS o
	WHERE c.CustomerID=o.CustomerID);

-- Use COUNT(*) > 0
SELECT CustomerID, CompanyName
FROM Sales.Customers AS c
WHERE (
	SELECT COUNT(*) 
	FROM Sales.Orders AS o
	WHERE c.CustomerID=o.CustomerID) > 0;


-- 找出 沒有 訂單的客戶
SELECT CustomerID, CompanyName
FROM Sales.Customers AS c
WHERE NOT EXISTS (
	SELECT * 
	FROM Sales.Orders AS o
	WHERE c.CustomerID=o.CustomerID);

-- Use COUNT(*) = 0
SELECT CustomerID, CompanyName
FROM Sales.Customers AS c
WHERE (
	SELECT COUNT(*) 
	FROM Sales.Orders AS o
	WHERE c.CustomerID=o.CustomerID) = 0;
		
 	