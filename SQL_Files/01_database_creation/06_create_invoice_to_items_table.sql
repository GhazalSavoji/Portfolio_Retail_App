-- ***********************************************************************************
-- FILE: 06_create_invoice_to_items_table.sql
-- DESCRIPTION: Create [Transaction].[invoice_to_items] table, BULK INSERT, FK to invoice_info
-- ***********************************************************************************

CREATE TABLE [Transaction].[invoice_to_items] (
    InvoiceItem_ID NVARCHAR(20) PRIMARY KEY,
    Invoice NVARCHAR(20),
    CONSTRAINT FK_InvoiceToItems_InvoiceInfo FOREIGN KEY (Invoice) REFERENCES [Transaction].[invoice_info](Invoice)
);
GO

-- Insert from CSV
BULK INSERT [Transaction].[invoice_to_items]
FROM 'C:\TempTables\invoice_to_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO
