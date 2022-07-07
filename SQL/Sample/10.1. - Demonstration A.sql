-- Demonstration A

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Window Ranking Functions
SELECT  ProductID ,
        ProductName ,
        UnitPrice ,
        RANK() OVER ( ORDER BY UnitPrice DESC ) AS PriceRank , -- 11, 11, 13
        DENSE_RANK() OVER ( ORDER BY UnitPrice DESC ) AS PriceDenseRank , -- 11, 11, 12
        NTILE(5) OVER ( ORDER BY UnitPrice DESC ) AS PriceNtile , --分群
        ROW_NUMBER() OVER ( ORDER BY UnitPrice DESC ) AS SN --流水號
FROM    Production.Products
ORDER BY SN

--以下SQL 2012才Support ******* 
-- Step 3: LAG & LEAD
SELECT  OrderYear ,
        LAG(Qty, 1, NULL) OVER ( ORDER BY OrderYear ) AS BeforeYearQty ,
        Qty ,
        LEAD(Qty, 1, 0) OVER ( ORDER BY OrderYear ) AS NextYearQty 
FROM    Sales.OrderTotalsByYear;


-- Step 4: Frame RunningQty 加總
SELECT  OrderYear ,
        LAG(Qty, 1, 0) OVER ( ORDER BY OrderYear ) AS BeforeYearQty , --前年的Qty
        Qty , --當年的Qty
		SUM(Qty) OVER (ORDER BY OrderYear 
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningQty, --到當年為止的Qty加總
        LEAD(Qty, 1, 0) OVER ( ORDER BY OrderYear ) AS NextYearQty, --下一年的Qty
		SUM(Qty) OVER () AS TotalQty --全部的Qty加總
FROM    Sales.OrderTotalsByYear;

 