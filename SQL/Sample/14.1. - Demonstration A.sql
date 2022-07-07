-- Demonstration A

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Create a table to support the demonstrations
-- Clean up if the tables already exists
IF OBJECT_ID('dbo.SimpleOrderDetails','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrderDetails;
IF OBJECT_ID('dbo.SimpleOrders','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrders;
GO


CREATE TABLE dbo.SimpleOrders(
	OrderID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	CustomerID int NOT NULL FOREIGN KEY REFERENCES Sales.Customers(CustomerID),
	EmployeeID int NOT NULL FOREIGN KEY REFERENCES HR.Employees(EmployeeID),
	OrderDate datetime NOT NULL
);
GO
CREATE TABLE dbo.SimpleOrderDetails(
	OrderID int NOT NULL FOREIGN KEY REFERENCES dbo.SimpleOrders(OrderID),
	ProductID int NOT NULL FOREIGN KEY REFERENCES Production.Products(ProductID),
	UnitPrice money NOT NULL,
	Qty smallint NOT NULL,
 CONSTRAINT PK_OrderDetails PRIMARY KEY (OrderID, ProductID)
);
GO

-- Step 3: Execute a multi-statement batch with error 
-- NOTE: THIS STEP WILL CAUSE AN ERROR

BEGIN TRY
	INSERT INTO dbo.SimpleOrders(CustomerID, EmployeeID, OrderDate) VALUES (68,9,'2006-07-12');
	INSERT INTO dbo.SimpleOrders(CustomerID, EmployeeID, OrderDate) VALUES (88,3,'2006-07-15');
	INSERT INTO dbo.SimpleOrderDetails(OrderID,ProductID,UnitPrice,Qty) VALUES (1, 2,15.20,20);
	--999的OrderID不存在dbo.SimpleOrders之中，所以發生錯誤
	INSERT INTO dbo.SimpleOrderDetails(OrderID,ProductID,UnitPrice,Qty) VALUES (999,77,26.20,15);
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
	THROW;
END CATCH;

-- Step 4: Show that even with exception handling, 
-- 交易不完整，有些資料insert 進去，有些沒進去
SELECT  OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.SimpleOrders;
SELECT  OrderID, ProductID, UnitPrice, Qty
FROM dbo.SimpleOrderDetails;


-- Step N: Clean up demonstration tables
IF OBJECT_ID('dbo.SimpleOrderDetails','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrderDetails;
IF OBJECT_ID('dbo.SimpleOrders','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrders;

	
-- Demonstration B
-- 加入交易處理 ****************************************
-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Create a table to support the demonstrations
-- Clean up if the tables already exists
IF OBJECT_ID('dbo.SimpleOrderDetails','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrderDetails;
IF OBJECT_ID('dbo.SimpleOrders','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrders;
GO
CREATE TABLE dbo.SimpleOrders(
	OrderID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	CustomerID int NOT NULL FOREIGN KEY REFERENCES Sales.Customers(CustomerID),
	EmployeeID int NOT NULL FOREIGN KEY REFERENCES HR.Employees(EmployeeID),
	OrderDate datetime NOT NULL
);
GO
CREATE TABLE dbo.SimpleOrderDetails(
	OrderID int NOT NULL FOREIGN KEY REFERENCES dbo.SimpleOrders(OrderID),
	ProductID int NOT NULL FOREIGN KEY REFERENCES Production.Products(ProductID),
	UnitPrice money NOT NULL,
	Qty smallint NOT NULL,
 CONSTRAINT PK_OrderDetails PRIMARY KEY (OrderID, ProductID)
);
GO

-- Step 3: Create a transaction to wrap around insertion statements
-- to create a single unit of work
BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO dbo.SimpleOrders(CustomerID, EmployeeID, OrderDate) VALUES (68,9,'2006-07-12');
		INSERT INTO dbo.SimpleOrderDetails(OrderID,ProductID,UnitPrice,Qty) VALUES (1, 2,15.20,20);
		SELECT XACT_STATE() AS [XACT_STATE]
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
	ROLLBACK TRANSACTION
END CATCH;

-- Step 4: Verify success
SELECT  OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.SimpleOrders;
SELECT  OrderID, ProductID, UnitPrice, Qty
FROM dbo.SimpleOrderDetails;

-- Step 5: Clear out rows from previous tests
DELETE FROM dbo.SimpleOrderDetails;
GO
DELETE FROM dbo.SimpleOrders;
GO

--Step 6: Execute with errors in data to test transaction handling
BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO dbo.SimpleOrders(CustomerID, EmployeeID, OrderDate) VALUES (68,9,'2006-07-15');
		--999的OrderID不存在dbo.SimpleOrders之中，所以發生錯誤
		INSERT INTO dbo.SimpleOrderDetails(OrderID,ProductID,UnitPrice,Qty) VALUES (99, 2,15.20,20);
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
	ROLLBACK TRANSACTION
END CATCH;

-- Step 7: Verify that no partial results remain
SELECT  OrderID, CustomerID, EmployeeID, OrderDate
FROM dbo.SimpleOrders;
SELECT  OrderID, ProductID, UnitPrice, Qty
FROM dbo.SimpleOrderDetails;


--測試最簡單的Blocking
--1.執行以下SQL
BEGIN TRANSACTION
INSERT INTO dbo.SimpleOrders(CustomerID, EmployeeID, OrderDate) VALUES (68,9,'2006-07-11');
INSERT INTO dbo.SimpleOrders(CustomerID, EmployeeID, OrderDate) VALUES (68,9,'2006-07-15');
SELECT * FROM dbo.SimpleOrders;
--2.Open New Window 執行以下的SQL會被Blocking
SELECT * FROM dbo.SimpleOrders 

--3.回到原Window執行 Commit
COMMIT
--4.再查看剛才new Window中的資料就會被查出來

/*
使用Rowversion
--
use master
go
declare @isql varchar(max)=''
select @isql=@isql+'kill '+cast(spid as varchar(10))+';' from master.dbo.sysprocesses
where db_name(dbid)='TSQL2012'
--execute(@isql)
select @isql 

ALTER DATABASE TSQL2012
    SET READ_COMMITTED_SNAPSHOT ON;

ALTER DATABASE TSQL2012
    SET ALLOW_SNAPSHOT_ISOLATION ON;

*/
-- Step N: Clean up demonstration tables
IF OBJECT_ID('dbo.SimpleOrderDetails','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrderDetails;
IF OBJECT_ID('dbo.SimpleOrders','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrders;

GO
