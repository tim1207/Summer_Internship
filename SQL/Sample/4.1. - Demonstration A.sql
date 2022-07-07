-- Demonstration A

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Join 2 tables
-- ANSI SQL-89 syntax
SELECT c.CompanyName, o.OrderDate
FROM Sales.Customers AS c, Sales.Orders AS o
WHERE c.CustomerID = o.CustomerID;

-- Step 3: CROSS JOIN 笛卡爾乘積 ANSI SQL-89 syntax
--SELECT COUNT(*)  FROM Sales.Customers; -- ?a
--SELECT COUNT(*)  FROM Sales.Orders; -- ?b
--SELECT ?a * ?b; --?c
SELECT c.CompanyName, o.OrderDate
FROM Sales.Customers AS c, Sales.Orders AS o;
 
-- Step 4: ANSI SQL-92 syntax
SELECT c.CompanyName, o.OrderDate
FROM Sales.Customers AS c JOIN Sales.Orders AS o
ON c.CustomerID = o.CustomerID;

-- Step 5: 用Inner/LEFT Join，沒有ON是不行的哦!
SELECT c.CompanyName, o.OrderDate
FROM Sales.Customers AS c INNER JOIN Sales.Orders AS o 
 ON c.CustomerID = o.CustomerID


--  Demonstration B

--  Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO


-- Step 3: Join 2 個欄位(有重覆的資料)
SELECT e.City, e.Country
FROM Sales.Customers AS c
JOIN HR.Employees AS e 
ON c.City = e.City AND c.Country = e.Country;

-- Step 4: 可加上之前說的DISTINCT來去除重覆的資料
SELECT DISTINCT  e.City, e.Country
FROM Sales.Customers AS c
JOIN HR.Employees AS e 
ON c.City = e.City AND c.Country = e.Country;

-- Step 5: Sales.Customers 跟 Sales.Orders 的Join
SELECT c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate -- , od.ProductID, od.Qty
FROM Sales.Customers AS c 
JOIN Sales.Orders AS o
ON c.CustomerID = o.CustomerID;
-- JOIN Sales.OrderDetails od
-- ON o.OrderID = od.OrderID;

-- Step 6: Sales.Customers、 Sales.Orders跟Sales.OrderDetails 的Join
-- 因為多Join了Detail，所以資料想當然變多了
SELECT c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate, od.ProductID, od.Qty
FROM Sales.Customers AS c 
JOIN Sales.Orders AS o
ON c.CustomerID = o.CustomerID
JOIN Sales.OrderDetails od
ON o.OrderID = od.OrderID;


-- Step 4: 使用Left Join，列出所有客戶訂單的資訊(包含沒訂單的)
SELECT c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate
FROM Sales.Customers AS c
LEFT OUTER JOIN Sales.Orders AS o
ON c.CustomerID =o.CustomerID
ORDER BY o.OrderID, c.CustomerID;

-- Step 5: 使用Left Join，找出沒有下訂單的客戶
SELECT c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate
FROM Sales.Customers AS c
LEFT OUTER JOIN Sales.Orders AS o
ON c.CustomerID =o.CustomerID
WHERE o.OrderID IS NULL;

 

-- Step 6: RIGHT OUTER JOIN
SELECT c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate
FROM Sales.Customers AS c
RIGHT OUTER JOIN Sales.Orders AS o
ON c.CustomerID =o.CustomerID;
-- Why 沒有 Null資料?

-- Step 7: RIGHT OUTER JOIN
SELECT c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate
FROM Sales.Customers AS c
RIGHT OUTER JOIN Sales.Orders AS o
ON c.CustomerID =o.CustomerID
WHERE c.CustomerID IS NULL;

-- 當Outer Join時，篩選條件應該要放在Where
--因為Orders沒資料，所以出來都是NULL
SELECT c.CustomerID, c.ContactName, o.OrderID, o.OrderDate
FROM Sales.Customers AS c LEFT JOIN Sales.Orders AS o
	ON c.CustomerID = o.CustomerID AND o.OrderID IS NULL;
--c91筆資料,o沒有任何資料=>就直接將c 91筆資料輸出


--找出沒有下訂單的客戶
SELECT c.CustomerID, c.ContactName, o.OrderID, o.OrderDate
FROM Sales.Customers AS c LEFT JOIN Sales.Orders AS o
ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;




--  Self Join

--  Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

--[ManagerID]放的是主管的EmployeeID
SELECT EmployeeID, LastName, FirstName, Title, [ManagerID] 
FROM HR.Employees;


-- Step 2: 找出員工及他的主管名稱
 SELECT e.EmployeeID ,e.LastName as EmpName,e.Title,e.[ManagerID], m.LastName as MgrName
  FROM HR.Employees AS e
  JOIN HR.Employees AS m
  ON e.[ManagerID]=m.EmployeeID;

-- Step 3: 找出所有員工(包含大老闆)及他的主管名稱
  SELECT e.EmployeeID ,e.LastName as EmpName,e.Title,e.[ManagerID], m.LastName as MgrName
  FROM HR.Employees AS e
  LEFT OUTER JOIN HR.Employees AS m
  ON e.[ManagerID]=m.EmployeeID;

  SELECT e.EmployeeID ,e.LastName as EmpName,e.Title,e.[ManagerID], ISNULL(m.LastName, N'股東') as MgrName
  FROM HR.Employees AS e
  LEFT OUTER JOIN HR.Employees AS m
  ON e.[ManagerID]=m.EmployeeID;
  

/*
5:Select
1:From
2:Where
3:Group
4:Having
6:Order By
*/




/*
--QUIZ

USE tempdb
GO

CREATE TABLE t1(
id INT 
, t1name VARCHAR(10)
)
GO

CREATE TABLE t2
(
id INT
, t2name VARCHAR(10)
)
GO

INSERT INTO t1(id, t1name) VALUES(1, 't1name');

INSERT INTO t2(id, t2name) VALUES(1, 't2name1-1');
INSERT INTO t2(id, t2name) VALUES(1, 't2name1-2');

SELECT *
FROM t1 LEFT JOIN t2
ON t1.id = t2.id;


SELECT *
FROM t1 JOIN  t2
ON t1.id = t2.id;

SELECT * FROM t1;
SELECT * FROM t2;

DROP TABLE t1;
DROP TABLE t2;



*/