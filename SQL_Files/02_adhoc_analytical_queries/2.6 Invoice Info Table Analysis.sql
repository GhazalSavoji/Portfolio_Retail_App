--=============================================
--SECTION 2-6: Analyzing 'invoice_info' table
--=============================================
--2.6.1 Check the table's structure and schema
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'invoice_info'
ORDER BY ORDINAL_POSITION
----Table schema
SELECT TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'invoice_info'
GO
--2.6.2 Day of week, month, and also hours with the highest number of invoces
-- Calculating the number of invoices per year
SELECT 
	YEAR(InvoiceDate) AS InvoiceYear,
	COUNT(Invoice) AS NumInvoices
FROM [Transaction].[invoice_info]
GROUP BY YEAR(InvoiceDate)
ORDER BY NumInvoices DESC;
--2.6.3 Day of the week with the highest number of invoices
SELECT 
    DATENAME(WEEKDAY, InvoiceDate) AS DayOfWeek,
    COUNT(*) AS InvoiceCount
FROM [Transaction].[invoice_info]
GROUP BY DATENAME(WEEKDAY, InvoiceDate)
ORDER BY InvoiceCount DESC;

--2.6.4 Month with the highest number of invoices
SELECT 
    DATENAME(MONTH, InvoiceDate) AS MonthName,
    COUNT(*) AS InvoiceCount
FROM [Transaction].[invoice_info]
GROUP BY DATENAME(MONTH, InvoiceDate)
ORDER BY InvoiceCount DESC;

-- DO the same with month() function
SELECT 
    MONTH(InvoiceDate) AS InvoiceMonth,
    COUNT(*) AS InvoiceCount
FROM [Transaction].[invoice_info]
GROUP BY MONTH(InvoiceDate)
ORDER BY InvoiceCount DESC;

--2.6.5 Hour of the day with the highest number of invoices
SELECT 
    DATEPART(HOUR, InvoiceDate) AS HourOfDay,
    COUNT(*) AS InvoiceCount
FROM [Transaction].[invoice_info]
GROUP BY DATEPART(HOUR, InvoiceDate)
ORDER BY InvoiceCount DESC;
GO
--2.6.7 The difference betwwn the first and last dates of invoices
SELECT 
	customer_id,
	DATEDIFF(DAY, MIN(InvoiceDate), MAX(InvoiceDate)) AS DayDiff
	FROM [Transaction].[invoice_info]
	GROUP BY customer_id
	ORDER BY DayDiff DESC;
GO
-- Show dates with style 23
SELECT 
    Invoice, 
    CONVERT(VARCHAR(10), InvoiceDate, 23) AS InvoiceDate_Formatted
FROM [Transaction].[invoice_info];
GO

--2.6.8. Countries with highest numbers of invoices
SELECT 
	country,
	COUNT(*) AS NumInvoices,
	COUNT(*)*100.0/SUM(COUNT(*))OVER() AS PercentInvoices
FROM [Transaction].[invoice_info]
GROUP BY country
ORDER BY NumInvoices DESC;

--2.6.9. Number of invoices per user
SELECT 
	customer_id,
	COUNT(Invoice) AS NumInvoices
FROM [Transaction].[invoice_info]
GROUP BY customer_id
ORDER BY NumInvoices DESC;

--2.6.10 Number of customers based on their purchse count
WITH PurchaseCount AS(
			SELECT
				customer_id,
				COUNT(Invoice) AS NumInvoices
			FROM [Transaction].[invoice_info]
			GROUP BY customer_id)

SELECT
	SUM(CASE WHEN NumInvoices BETWEEN 10 AND 100 THEN 1 ELSE 0 END) AS ActiveCustomers,
	SUM(CASE WHEN NumInvoices > 100 THEN 1 ELSE 0 END) AS LoyalCustomers,
	SUM(CASE WHEN NumInvoices <10 THEN 1 ELSE 0 END) AS LowQualityCustomers
FROM PurchaseCount
GO
--2.6.11 Average number of invoices per customer compared to the overall customer average.
SELECT 
    customer_id,
    COUNT(*) AS NumInvoices,
    (SELECT AVG(Count_Cust)  --Subquery
	FROM (
	SELECT customer_id, COUNT(*) AS Count_Cust
	FROM [Transaction].[invoice_info] 
	GROUP BY customer_id
		) AS CustomersCount
	) AS AvgInvoicesPerCustomer
FROM [Transaction].[invoice_info]
GROUP BY customer_id; --This could be done through CTE and Windows function for better performance
GO
--2.6.12 Customers with an invoice count greater than the average.
SELECT 
	customer_id,
	COUNT(*) AS InvoiceCount
FROM [Transaction].[invoice_info]
GROUP BY customer_id
HAVING COUNT(*) > (
			SELECT AVG(Count_Cust)  
			FROM (
				SELECT customer_id, COUNT(*) AS Count_Cust
				FROM [Transaction].[invoice_info] 
				GROUP BY customer_id
				) AS CustomersCount
					);
