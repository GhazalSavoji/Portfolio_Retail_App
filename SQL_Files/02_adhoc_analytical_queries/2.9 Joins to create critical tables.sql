--=============================================
-- SECTION 2-9: Join practices
--=============================================
-- 2.9. Users with their devices in a table
SELECT
	u.user_id,
	u.location_country,
	u.location_city,
	u.is_subscribed,
    u.user_age,
	d.device_id,
	d.device_os,
    d.device_model,
    d.app_language
FROM [Users].[user] u
LEFT JOIN [Users].[device] d
ON u.user_id = d.user_id;

--- how many rows
SELECT COUNT(*) AS TotalRows
FROM [Users].[user] u
LEFT JOIN [Users].[device] d
ON u.user_id = d.user_id;
GO

--2.9.2 A complete table containing user, device, session, and event_type info
-- use filters
SELECT
    u.user_id,
    u.location_city,
	u.location_country,
	u.user_age,
	u.is_subscribed,
	d.device_id,
	d.device_os,
    d.device_model,
    d.app_language,  
    s.session_id,
    s.session_duration_sec,
	s.push_enabled,
    e.event_type,
    e.event_target,
	e.Time_stamp,
	e.Invoice
FROM [Events].[event_types] e
LEFT JOIN [Events].[session] s ON e.session_id = s.session_id
LEFT JOIN [Users].[user] u ON u.user_id = e.user_id
LEFT JOIN [Users].[device] d ON u.user_id = d.user_id
WHERE YEAR(TRY_CAST(e.Time_stamp AS DATETIME2))= 2024 
	AND u.user_age >= 15
    AND s.session_duration_sec > 0;
GO
-- Do the same with 'EXISTS"
SELECT
    u.user_id,
    u.location_city,
    u.location_country,
    u.user_age,
    u.is_subscribed,
    d.device_id,
    d.device_os,
    d.device_model,
    d.app_language,  
    s.session_id,
    s.session_duration_sec,
    s.push_enabled,
    e.event_type,
    e.event_target,
    e.Time_stamp,
    e.Invoice
FROM [Events].[event_types] e
INNER JOIN [Events].[session] s ON e.session_id = s.session_id
INNER JOIN [Users].[user] u ON u.user_id = e.user_id
LEFT JOIN [Users].[device] d ON u.user_id = d.user_id
WHERE EXISTS ( 
    SELECT 1 FROM [Users].[user] u2 
    WHERE u2.user_id = e.user_id AND u2.user_age >= 15
)
AND YEAR(TRY_CAST(e.Time_stamp AS DATETIME2)) = 2024 
AND s.session_duration_sec > 0;

--2.9.3 A table to show all invoices and sales info together
SELECT
    s.InvoiceItem_ID,
    s.StockCode,
    s.S_Description,
    s.Quantity,
    s.Price,
	ii.Invoice,
	iinf.InvoiceDate,
	iinf.Customer_ID,
	iinf.Country	
FROM [Transaction].[invoice_to_items] ii 
LEFT JOIN [Transaction].[sales_info] s
ON ii.InvoiceItem_ID = s.InvoiceItem_ID 
LEFT JOIN [Transaction].[invoice_info] iinf
ON ii.Invoice = iinf.Invoice
ORDER BY s.InvoiceItem_ID DESC;


---How many rows?
SELECT
	COUNT(*) AS RowsNumAfterJoin
FROM [Transaction].[invoice_to_items] ii 
LEFT JOIN [Transaction].[sales_info] s
ON ii.InvoiceItem_ID = s.InvoiceItem_ID
LEFT JOIN [Transaction].[invoice_info] iinf
ON iinf.Invoice = ii.Invoice;
GO

--2.9.4 A table joinin event_type with Invoices' information
WITH InvoiceSummary AS (
		SELECT
			s.InvoiceItem_ID AS InvoiceItem_ID,
			s.StockCode AS StockCode,
			s.S_Description AS S_Description,
			s.Quantity AS Quantity,
			s.Price AS Price,
			ii.Invoice AS Invoice,
			iinf.InvoiceDate AS InvoiceDate,
			iinf.Customer_ID AS Customer_ID,
			iinf.Country AS Country	
		FROM [Transaction].[invoice_to_items] ii 
		LEFT JOIN [Transaction].[sales_info] s
		ON ii.InvoiceItem_ID = s.InvoiceItem_ID 
		LEFT JOIN [Transaction].[invoice_info] iinf
		ON ii.Invoice = iinf.Invoice
)
SELECT
    e.event_type_id,
    e.Time_stamp,
    e.session_id,
    e.user_id,
    e.event_type,
    e.event_target,
    e.event_value,
    isum.Invoice,
	isum.InvoiceItem_ID,
	isum.StockCode,
	isum.S_Description,
	isum.Quantity,
	isum.Price,
	isum.InvoiceDate,
	isum.Customer_ID,
	isum.Country
FROM InvoiceSummary isum
LEFT JOIN [Events].[event_types] e
ON isum.Invoice= e.Invoice;

--2.9.5 A table joing information like:
-- push_enables and session duration with sales total information
-- using CTEs
WITH InvoiceSummary AS (
		SELECT
			s.InvoiceItem_ID AS InvoiceItem_ID,
			s.StockCode AS StockCode,
			s.S_Description AS S_Description,
			s.Quantity AS Quantity,
			s.Price AS Price,
			ii.Invoice AS Invoice,
			iinf.InvoiceDate AS InvoiceDate,
			iinf.Customer_ID AS Customer_ID,
			iinf.Country AS Country	
		FROM [Transaction].[invoice_to_items] ii 
		LEFT JOIN [Transaction].[sales_info] s
		ON ii.InvoiceItem_ID = s.InvoiceItem_ID 
		LEFT JOIN [Transaction].[invoice_info] iinf
		ON ii.Invoice = iinf.Invoice
),
EventTypeSummary AS(
SELECT
    e.event_type_id,
    e.Time_stamp,
    e.session_id,
    e.user_id,
    e.event_type,
    e.event_target,
    e.event_value,
    isum.Invoice,
	isum.InvoiceItem_ID,
	isum.StockCode,
	isum.S_Description,
	isum.Quantity,
	isum.Price,
	isum.InvoiceDate,
	isum.Customer_ID,
	isum.Country
FROM InvoiceSummary isum
LEFT JOIN [Events].[event_types] e
ON isum.Invoice= e.Invoice
)
SELECT 
	ets.event_type_id,
    ets.session_id,
    ets.user_id,
    ets.event_type,
    ets.event_target,
    ets.event_value,
    ets.Invoice,
	ets.InvoiceItem_ID,
	ets.Quantity,
	ets.Price,
	ets.InvoiceDate,
	ets.Customer_ID,
	ets.Country,
    s.timestamp,
    s.session_duration_sec,
    s.push_enabled
FROM EventTypeSummary ets
LEFT JOIN [Events].[session] s
ON ets.session_id = s.session_id
-- 2.9.6 A table joing information like:
-- push_enables and session duration with sales total information
-- without CTEs for better performance:
SELECT 
    e.event_type_id,
    e.session_id,
    e.user_id,
    e.event_type,
    e.event_target,
    e.event_value,
    ii.Invoice,
    s.InvoiceItem_ID,
    s.Quantity,
    s.Price,
    iinf.InvoiceDate,
    iinf.Customer_ID,
    iinf.Country,
    sess.timestamp,
    sess.session_duration_sec,
    sess.push_enabled
FROM [Transaction].[invoice_to_items] ii 
LEFT JOIN [Transaction].[sales_info] s ON ii.InvoiceItem_ID = s.InvoiceItem_ID 
LEFT JOIN [Transaction].[invoice_info] iinf ON ii.Invoice = iinf.Invoice
LEFT JOIN [Events].[event_types] e ON ii.Invoice = e.Invoice
LEFT JOIN [Events].[session] sess ON e.session_id = sess.session_id;


--2.9.7 Conversion Rate (Users to Buyers) by Country
WITH CountryStat AS
(
		SELECT
			location_country,
			COUNT(*) AS TotalUserCountry
		FROM [Users].[user]
		GROUP BY location_country
),
Buyers AS
(
		SELECT DISTINCT user_id
		FROM [Events].[event_types] AS evt
		WHERE evt.Invoice IS NOT NULL
)
SELECT 
	u.location_country,
	cs.TotalUserCountry,
	COUNT(b.user_id) AS BuyerCount,
	COUNT(b.user_id)*100.0/cs.TotalUserCountry AS UserToBuyerConver
FROM [Users].[user] u
LEFT JOIN Buyers b
ON u.user_id = b.user_id
LEFT JOIN CountryStat cs
ON u.location_country = cs.location_country
GROUP BY u.location_country,cs.TotalUserCountry
ORDER BY UserToBuyerConver DESC;

-- Do the same with 'EXISTS':
WITH UserBuyer AS (
    SELECT 
        u.user_id,
        u.location_country,
        CASE WHEN EXISTS (
            SELECT 1 
            FROM Events.event_types evt
            WHERE evt.user_id = u.user_id AND evt.Invoice IS NOT NULL
        ) THEN 1 ELSE 0 END AS IsBuyer
    FROM Users.[user] u
)

SELECT 
    location_country,
    COUNT(*) AS TotalUsers,
    SUM(IsBuyer) AS BuyerCount,
    SUM(IsBuyer) * 100.0 / COUNT(*) AS UserToBuyerConver
FROM UserBuyer
GROUP BY location_country
ORDER BY UserToBuyerConver DESC;

--2.9,8 Number of User Events Before First Purchase
WITH FirstPurchase AS
(
			SELECT *
				FROM(
					SELECT
						user_id,
						Invoice,
						TRY_CAST(Time_stamp AS DATETIME2) AS Timestampt,
						ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY TRY_CAST(Time_stamp AS DATETIME2)) AS rn
					FROM Events.event_types
					WHERE Invoice IS NOT NULL
					) AS FirstPurchases
			WHERE rn =1
)
SELECT 
	COUNT(et.event_type_id) AS B4PurchaseEvents,
	fp.user_id
FROM FirstPurchase fp
LEFT JOIN Events.event_types et
ON fp.user_id = et.user_id
AND TRY_CAST(et.Time_stamp AS DATETIME2) < fp.Timestampt
GROUP BY fp.user_id
ORDER BY B4PurchaseEvents DESC;

--2.9.9 Wonthly Active Users (WAU)
SELECT
    DATEPART(YEAR, timestamp) AS Year,
    DATEPART(MONTH, timestamp) AS MOnthNum,
    COUNT(DISTINCT user_id) AS MAU
FROM Events.session
GROUP BY 
    DATEPART(YEAR, timestamp),
    DATEPART(MONTH, timestamp)
ORDER BY MAU DESC;

