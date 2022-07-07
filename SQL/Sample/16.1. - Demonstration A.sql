-- Demonstration A

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- 一次新增1筆資料
INSERT INTO Sales.OrderDetails(
OrderID, ProductID, UnitPrice, Qty, Discount)
VALUES(10248,39,18,2,0.05);

-- 一次新增2筆資料
INSERT INTO Sales.OrderDetails(
OrderID, ProductID, UnitPrice, Qty, Discount)
VALUES
	(10248,40,18,2,0.05), 
	(10248,41,18,5,0.10);

--新增同時建立資料表	
SELECT OrderID, CustomerID, EmployeeID, OrderDate, ShippedDate
INTO Sales.OrderArchive
FROM Sales.Orders
WHERE OrderDate < '20080101';

select * from Sales.OrderArchive;

drop table Sales.OrderArchive;

--更新資料
SELECT * FROM Production.Products;

UPDATE Production.Products
   SET UnitPrice = (UnitPrice * 1.5)
WHERE CategoryID =  1 AND Discontinued = 0;

SELECT * FROM Production.Products;


--刪資資料
select * from Sales.OrderDetails
WHERE OrderID >10000;

DELETE FROM Sales.Customers 
where CustomerID = 10;

begin tran

DELETE FROM Sales.OrderDetails
WHERE OrderID = 10248;

select * from Sales.OrderDetails
WHERE OrderID = 10247;
rollback;

--Merge
--建立空的資料表
SELECT *
INTO Sales.OrderDetailsHistory
FROM Sales.OrderDetails
WHERE 1 = 2;

 

SELECT *
FROM Sales.OrderDetails;

INSERT INTO Sales.OrderDetailsHistory(
OrderID, ProductID, UnitPrice, Qty, Discount)
VALUES
	(10248,40,18,2,0.05), 
	(10248,41,18,5,0.10),
	(10248,1,1,1,0.11),
	(10248,2,2,2,0.22),
	(10248,11,13,1,0.05);

BEGIN TRAN

--merge= insert + update + delete
merge INTO Sales.OrderDetails AS Target
using (select * from Sales.OrderDetailsHistory) as Source
on (Target.OrderID=Source.OrderID AND Target.ProductID = Source.ProductID)
WHEN MATCHED THEN --修改
     UPDATE SET Qty = Source.Qty, 
	 Discount = Source.Discount,
	 UnitPrice = Source.UnitPrice
WHEN NOT MATCHED THEN --新增
     INSERT(OrderID, ProductID, UnitPrice, Qty, Discount)
	VALUES (Source.OrderID, Source.ProductID, Source.UnitPrice, Source.Qty, Source.Discount)
	;
--WHEN NOT MATCHED BY Source Then
--	Delete;  



SELECT *
FROM Sales.OrderDetails;

ROLLBACK;

DROP TABLE Sales.OrderDetailsHistory;


-- Define a sequence
CREATE SEQUENCE dbo.InvoiceSeq AS INT START WITH 1 INCREMENT BY 1;
-- Retrieve next available value from sequence
SELECT NEXT VALUE FOR dbo.InvoiceSeq;


--clean up
DROP SEQUENCE dbo.InvoiceSeq;
GO
