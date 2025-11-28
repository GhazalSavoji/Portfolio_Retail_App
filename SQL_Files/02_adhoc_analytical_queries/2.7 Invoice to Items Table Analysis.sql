--=============================================
--SECTION 2-7: Analyzing 'invoice_to_items' table
--=============================================
--2.7.1 Check the table's structure and schema
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'invoice_to_items'
ORDER BY ORDINAL_POSITION
----Table schema
SELECT TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'invoice_to_items'
GO
-- 2.7.2. Invoice items' counts
SELECT 
	Invoice,
	COUNT(InvoiceItem_ID) AS NumItems
FROM [Transaction].[invoice_to_items]
GROUP BY Invoice
ORDER BY NumItems DESC;
GO
--2.7.3 Number of invoices based on their number of items
WITH InvoceItems AS(
		SELECT 
			Invoice,
			COUNT(InvoiceItem_ID) AS NumItems
		FROM [Transaction].[invoice_to_items]
		GROUP BY Invoice)
SELECT 
    SUM(CASE WHEN NumItems <= 10 THEN 1 ELSE 0 END) AS under_10_items,
	SUM(CASE WHEN NumItems BETWEEN 11 AND 100 THEN 1 ELSE 0 END) AS items_10_100,
	SUM(CASE WHEN NumItems BETWEEN 101 AND 200 THEN 1 ELSE 0 END) AS items_100_200,
	SUM(CASE WHEN NumItems > 200 THEN 1 ELSE 0 END) AS More_200_items_wholesale
FROM InvoceItems