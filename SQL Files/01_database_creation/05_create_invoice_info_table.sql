-- ***********************************************************************************
-- FILE: 05_create_invoice_info_table.sql
-- DESCRIPTION: Create [Transaction].[invoice_info] table and BULK INSERT
-- ***********************************************************************************

CREATE TABLE [Transaction].[invoice_info] (
    Invoice NVARCHAR(20) PRIMARY KEY,
    InvoiceDate NVARCHAR(50),
    Customer_ID NVARCHAR(20),
    Country NVARCHAR(20)
);
GO

-- Insert from CSV
BULK INSERT [Transaction].[invoice_info]
FROM 'C:\TempTables\invoice_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Convert InvoiceDate to DATETIME
ALTER TABLE [Transaction].[invoice_info] ALTER COLUMN InvoiceDate DATETIME;
GO
