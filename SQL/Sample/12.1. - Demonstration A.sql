-- Demonstration A
-- Stored Procedure *************************************** 
-- Step 1: Open a new query window to the TSQL2012 database
USE [TSQL2012]
GO


-- Step 2: create basic procedure with single input parameter
IF OBJECT_ID('Production.ProductsbySuppliers') IS NOT NULL
	DROP PROC Production.ProductsbySuppliers;
GO

CREATE PROCEDURE Production.ProductsbySuppliers
(@SupplierID AS INT)
AS
SELECT  ProductID,
        ProductName,
        CategoryID,
        UnitPrice,
        Discontinued
FROM Production.Products
WHERE   SupplierID = @SupplierID
ORDER BY ProductID;
GO

-- Step 3: Test procedure
EXEC Production.ProductsbySuppliers @SupplierID = 2;
GO


-- Step 4: 參數使用預設值
ALTER PROCEDURE Production.ProductsbySuppliers
(@SupplierID AS INT, @NumRows AS BIGINT = 9223372036854775807) --largest possible value for a bigint (9,223,372,036,854,775,807)
AS
SELECT  TOP (@NumRows) ProductID,
        ProductName,
        CategoryID,
        UnitPrice,
        Discontinued
FROM Production.Products
WHERE   SupplierID = @SupplierID
ORDER BY ProductID;
GO

-- Step 4: Test procedure
EXEC Production.ProductsbySuppliers @SupplierID = 2, @NumRows = 2;

--不給參數，會使用預設值
EXEC Production.ProductsbySuppliers 2;
EXEC Production.ProductsbySuppliers 2, 1;

-- Step 5: Clean up
IF OBJECT_ID('Production.ProductsbySuppliers','P') IS NOT NULL 
	DROP PROCEDURE Production.ProductsbySuppliers;
GO


-- 建立有output參數的SP **************************************************
IF OBJECT_ID('Sales.GetCustPhone','P') IS NOT NULL 
	DROP PROCEDURE Sales.GetCustPhone;
GO

CREATE PROC Sales.GetCustPhone
(@CustomerID AS INT,
 @Phone AS nvarchar(24)OUTPUT)
AS
SELECT @Phone = Phone
FROM Sales.Customers
WHERE CustomerID=@CustomerID;
GO

-- 取得回傳值
DECLARE @CustomerID INT =5, @PhoneNum NVARCHAR(24);
EXEC Sales.GetCustPhone @CustomerID=@CustomerID, @Phone=@PhoneNum OUTPUT;
SELECT @CustomerID AS CustomerID, @PhoneNum AS Phone;

-- Step 5: Clean up
IF OBJECT_ID('Sales.GetCustPhone','P') IS NOT NULL 
	DROP PROCEDURE Sales.GetCustPhone;


 

-- Dynamic SQL **********************************************
--Step 2: Using EXEC to execute dynamic SQL
DECLARE @SQLString AS VARCHAR(1000);
SET @SQLString='SELECT EmployeeID, LastName FROM HR.Employees;'
EXEC(@SQLString);
GO
-- Step 3: Using sys.sp_executesql to execute dynamic SQL
-- Simple example with no parameters
DECLARE @SQLCode AS NVARCHAR(256) = N'SELECT GETDATE() AS DT';
EXEC sys.sp_executesql @Statement = @SQLCode;
GO
-- Step 4: Example with a single input parameter
DECLARE @SQLString AS NVARCHAR(1000);
DECLARE @EmployeeID AS INT;
SET @SQLString=N'
	SELECT EmployeeID, LastName 
	FROM HR.Employees
	WHERE EmployeeID=@EmployeeID;'
EXEC sys.sp_executesql 
	@Statement = @SQLString,
	@Params=N'@EmployeeID AS INT',
	@EmployeeID = 5;
GO
