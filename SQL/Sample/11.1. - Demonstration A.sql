-- Demonstration A
-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO
IF OBJECT_ID('Sales.CategoryQtyYear','V') IS NOT NULL 
	DROP VIEW Sales.CategoryQtyYear
GO
-- Step 2: Create view for inner derived table (for screen space/convenience)
CREATE VIEW Sales.CategoryQtyYear
AS
SELECT  c.CategoryName AS Category,
        od.Qty AS Qty,
        YEAR(o.OrderDate) AS OrderYear
FROM    Production.Categories AS c
        INNER JOIN Production.Products AS p ON c.CategoryID=p.CategoryID
        INNER JOIN Sales.OrderDetails AS od ON p.ProductID=od.ProductID
        INNER JOIN Sales.Orders AS o ON od.OrderID=o.OrderID;
GO 
-- Step 3: Test view, review data
SELECT  Category, Qty,OrderYear
FROM Sales.CategoryQtyYear
ORDER BY Category;

-- Step 4: PIVOT and UNPIVOT
SELECT Category, [2006],[2007],[2008]
FROM ( SELECT Category, Qty, OrderYear 
	 FROM Sales.CategoryQtyYear) AS D 
PIVOT(SUM(Qty) FOR OrderYear 
		IN([2006],[2007],[2008])
		) AS pvt
ORDER BY Category;

 

-- Step 6: UNPIVOT
--利用CTE把原本Pivot的資料，Unpivot
WITH CategorySales
AS(
SELECT  Category, [2006],[2007],[2008]
FROM (SELECT  Category, Qty, OrderYear FROM Sales.CategoryQtyYear) AS D 
PIVOT(SUM(Qty) FOR OrderYear 
IN ([2006],[2007],[2008])) AS pvt
)
SELECT Category, Qty, OrderYear
FROM CategorySales
UNPIVOT(Qty FOR OrderYear IN([2006],[2007],[2008])) AS unpvt;

-- Step 7: Clean up
IF OBJECT_ID('Sales.CategoryQtyYear','V') IS NOT NULL 
	DROP VIEW Sales.CategoryQtyYear
GO
