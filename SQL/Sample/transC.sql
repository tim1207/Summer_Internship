USE TSQL2012;
GO

SELECT * FROM  Sales.Orders WHERE OrderID = 11054

BEGIN TRAN

	UPDATE Sales.Orders  SET ShippedDate = getdate() WHERE OrderID = 11054
	
COMMIT

SELECT * FROM  Sales.Orders WHERE OrderID = 11054

--UPDATE Sales.Orders  SET ShippedDate = null WHERE OrderID = 11054