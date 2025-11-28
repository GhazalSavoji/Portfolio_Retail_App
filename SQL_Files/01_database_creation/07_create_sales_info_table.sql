-- ***********************************************************************************
-- FILE: 07_create_sales_info_table.sql
-- DESCRIPTION: Create [Transaction].[sales_info] table, BULK INSERT, FK to invoice_to_items
-- ***********************************************************************************

CREATE TABLE [Transaction].[sales_info] (
    InvoiceItem_ID NVARCHAR(20) PRIMARY KEY,
    StockCode NVARCHAR(50),
    S_Description NVARCHAR(300),
    Quantity NVARCHAR(50),
    Price NVARCHAR(50),
    CONSTRAINT FK_SalesInfo_InvoiceToItems FOREIGN KEY (InvoiceItem_ID) REFERENCES [Transaction].[invoice_to_items](InvoiceItem_ID)
);
GO

-- Insert from CSV
BULK INSERT [Transaction].[sales_info]
FROM 'C:\TempTables\sales_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO
