USE TSQL2012;
GO

BEGIN TRAN

	UPDATE Sales.Orders  SET ShippedDate = getdate() WHERE OrderID = 11051
	
--ROLLBACK