--Programming with T-SQL
-- Demonstration A

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

  
--Run the following batch in its entirety to show the choices 
--for assigning values to variables
DECLARE @var1 INT = 99;

DECLARE @var2 NVARCHAR(20);
SET @var2 = N'string';

DECLARE @var3 NVARCHAR(10);
SELECT @var3 =  COALESCE(@var3 + ', ' + LastName ,  LastName ) 
FROM HR.Employees;

SELECT @var1 AS var1, @var2 AS var2, @var3 AS var3;
--Why @var3的資料不全???
GO 

-- Step 7: Synonyms

-- Clean up if the procedure already exists
IF OBJECT_ID('Production.ProdsByCategory','P') IS NOT NULL
	DROP PROC Production.ProdsByCategory;
GO

-- Declare a parameter to search for category
-- and a parameter to limit the number of results
CREATE PROC Production.ProdsByCategory
(@NumRows AS int, @CategoryID AS int)
 AS
SELECT TOP(@NumRows) ProductID, ProductName, UnitPrice
FROM Production.Products
WHERE CategoryID = @CategoryID;
GO

-- Test it locally
DECLARE @NumRows INT = 3, @CategoryID INT = 2;
EXEC Production.ProdsByCategory @NumRows = @NumRows, @CategoryID = @CategoryID;

-- Step 8: Switch databases - skip this if demonstrating on Azure
USE tempdb;
GO
-- Otherwise in Azure continue from this point
-- Step 9: Create synonym
CREATE SYNONYM dbo.ProdsByCategory FOR TSQL2012.Production.ProdsByCategory;
EXEC dbo.ProdsByCategory @NumRows = 3, @CategoryID = 2;
GO

-- Step 10: Query system view to see defined synonyms
SELECT *
FROM sys.synonyms;
GO


--Step 11: Clean up
USE tempdb
go
 
IF OBJECT_ID('dbo.ProdsByCategory' ) IS NOT NULL
	DROP SYNONYM dbo.ProdsByCategory;
GO

USE TSQL2012;
GO

IF OBJECT_ID('Production.ProdsByCategory','P') IS NOT NULL
	DROP PROC Production.ProdsByCategory;
GO



-- Demonstration B
-- Control of Flow ......................

-- Step 1: Open a new query window to the TSQL2012 database
USE TSQL2012;
GO

-- Step 2: Control of Flow
--IF..ELSE

IF OBJECT_ID('Production.ProdsByCategory','P') IS NULL
	PRINT 'Object does not exist';
ELSE
	DROP PROC Production.ProdsByCategory;
GO
-- Step 3: Examples from workbook
USE TSQL2012;
GO
IF OBJECT_ID('HR.Employees') IS NULL
BEGIN
	PRINT 'The specified object does not exist';
END;

IF OBJECT_ID('HR.Employees') IS NULL
BEGIN
	PRINT 'The specified object does not exist';
END
ELSE
BEGIN
	PRINT 'The specified object exists';
END;

-- Step 4: Demonstrate IF EXIST
IF EXISTS (SELECT * FROM Sales.EmpOrders WHERE EmployeeID =5)
	BEGIN
		PRINT 'Employee has associated orders';
	END;
GO


-- Step 5: WHILE
DECLARE @EmployeeID AS INT, @LastName AS NVARCHAR(20);
SET @EmployeeID = 1
WHILE @EmployeeID <=5
BEGIN
	SELECT @LastName = LastName FROM HR.Employees
		WHERE EmployeeID = @EmployeeID;
	PRINT @LastName;
	SET @EmployeeID += 1;
	CONTINUE
	--以下的內容不會被執行
	PRINT '我不會被執行到'
END;


