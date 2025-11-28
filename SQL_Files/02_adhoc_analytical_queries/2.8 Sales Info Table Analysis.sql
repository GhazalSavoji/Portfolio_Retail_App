--=============================================
-- SECTION 2-8: Analyzing 'sales_info' table
--=============================================
--2.8.1 Check the table's structure and schema
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales_info'
ORDER BY ORDINAL_POSITION
----Table schema
SELECT TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'sales_info'
GO
--- take a look at data
SELECT TOP 100 *
FROM [Transaction].[sales_info]
ORDER BY StockCode
GO
--2.8.2 Number of each product (Stockcode) sold
SELECT 
	si.StockCode,
	COUNT(DISTINCT et.user_id) AS UniqueBuyer,
	SUM(TRY_CAST(si.Quantity AS INT)) AS NumSold,
	SUM(TRY_CAST(si.Quantity AS INT)* TRY_CAST (si.Price AS FLOAT)) AS TotalValue,
	SUM(TRY_CAST(si.Quantity AS INT))*1.0/SUM(SUM(TRY_CAST(si.Quantity AS INT))) OVER() AS QuantitySalesShare,
	SUM(TRY_CAST(si.Quantity AS INT)* TRY_CAST (si.Price AS FLOAT))*100.0/SUM(SUM(TRY_CAST(si.Quantity AS INT)* TRY_CAST (si.Price AS FLOAT))) OVER() AS ValueSalesShare
FROM [Transaction].[sales_info] si
LEFT JOIN [Transaction].[invoice_to_items] iti
ON si.InvoiceItem_ID = iti.InvoiceItem_ID
LEFT JOIN [Events].[event_types] et
ON iti.Invoice = et.Invoice
WHERE TRY_CAST(si.Quantity AS INT) > 0 AND et.Invoice IS NOT NULL
GROUP BY si.StockCode
ORDER BY QuantitySalesShare DESC;
GO
-- Do the same with better performance
-- Using CTE, and inner joins
WITH UniqueBuyers AS
(
    SELECT DISTINCT 
        Invoice,
        user_id
    FROM [Events].[event_types]
    WHERE Invoice IS NOT NULL
),
SalesCleaned AS
(
    SELECT
        TRY_CAST(Quantity AS INT) AS QuantityFormated,
        TRY_CAST(Price AS FLOAT) AS PriceFormated,
        InvoiceItem_ID,
        StockCode
    FROM [Transaction].[sales_info]
    WHERE TRY_CAST(Quantity AS INT) > 0 
      AND TRY_CAST(Price AS FLOAT) > 0
)
SELECT 
    sc.StockCode AS ProductCode,
    COUNT(ub.user_id) AS BuyerCount,
    SUM(sc.QuantityFormated) AS TotalUnitsSold,
    SUM(sc.QuantityFormated * sc.PriceFormated) AS TotalRevenue,

    CAST(SUM(sc.QuantityFormated) AS FLOAT)
        / SUM(SUM(sc.QuantityFormated)) OVER() AS UnitsSalesShare,

	 SUM(sc.QuantityFormated * sc.PriceFormated) * 100.0
        / SUM(SUM(sc.QuantityFormated * sc.PriceFormated)) OVER() AS ValueSalesShare

FROM SalesCleaned sc
INNER JOIN [Transaction].[invoice_to_items] iti
    ON sc.InvoiceItem_ID = iti.InvoiceItem_ID
INNER JOIN UniqueBuyers ub
    ON ub.Invoice = iti.Invoice
GROUP BY sc.StockCode
ORDER BY UnitsSalesShare DESC;

