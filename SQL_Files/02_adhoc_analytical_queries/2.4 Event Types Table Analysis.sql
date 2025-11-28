--=============================================
--SECTION 2-4: Analyzing 'event_type' table
--=============================================
-- 2.4.1 Check tha table's structure and schema
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'event_types'
ORDER BY ORDINAL_POSITION

----Table schema
SELECT TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'event_types'
GO
--2.4.2. Count event_types and invoices
SELECT 
	event_type,
	COUNT(session_id) AS EventTypesCount,
	COUNT(DISTINCT Invoice) AS Inovice_per_Type
FROM Events.[event_types]
GROUP BY event_type
ORDER BY EventTypesCount DESC;

--2.4.3. Event_targets counts and number of invoices per target
SELECT event_target,
	COUNT(session_id) AS EventTargetCount,
	COUNT(DISTINCT Invoice) AS Inovice_per_Target
FROM Events.[event_types]
GROUP BY event_target
ORDER BY EventTargetCount DESC; --*Result: invoices have 'view' event_types and 'tank you page' target

--2.4.4. Number of invoices and unique invoices
SELECT 
	COUNT(Invoice) AS N_invoices,
	COUNT(DISTINCT Invoice) AS N_U_invoices 
FROM Events.[event_types] --*Result: Each invoice has only 1 event-type in the table


--2.4.5 number of event-types for each session_id
SELECT 
	session_id,
	COUNT(event_type) AS N_event_types
FROM Events.[event_types]
GROUP BY session_id
ORDER BY N_event_types DESC;

--2.4.6 Check contingency, every session should have a unique timestamp
SELECT 
	session_id,
	COUNT(DISTINCT Time_stamp) AS unique_timestamp_count
FROM Events.[event_types]
GROUP BY session_id
ORDER BY unique_timestamp_count DESC; --*Result: No contingency, each session_id has one timestamp
GO

--2.4.7 Days of month with the highest numbers of events and invoces
SELECT 
    DATEPART(DAY, TRY_CAST(Time_stamp AS DATETIME2)) AS event_day,
    COUNT(DISTINCT session_id) AS session_count,
	COUNT(Invoice) AS invoice_count
FROM Events.event_types
WHERE TRY_CAST(Time_stamp AS DATE) IS NOT NULL
GROUP BY  DATEPART(DAY, TRY_CAST(Time_stamp AS DATETIME2))
ORDER BY invoice_count DESC;
GO

--2.4.8. Days of weeK with the highest numbers of events and invoces
SELECT 
    DATEPART(WEEKDAY, TRY_CAST(Time_stamp AS DATETIME2)) AS event_weekday,
    COUNT(DISTINCT session_id) AS session_count,
	COUNT(Invoice) AS invoice_count
FROM Events.event_types
WHERE TRY_CAST(Time_stamp AS DATE) IS NOT NULL
GROUP BY DATEPART(WEEKDAY, TRY_CAST(Time_stamp AS DATETIME2))
ORDER BY invoice_count DESC;
GO

--2.4.9 Hours with the highest numbes of events and invoces
SELECT 
    DATEPART(HOUR, TRY_CAST(Time_stamp AS DATETIME2)) AS event_hour,
    COUNT(*) AS Total_events,
	COUNT(DISTINCT Invoice) AS Total_invoices
FROM Events.event_types
WHERE TRY_CAST(Time_stamp AS DATETIME2) IS NOT NULL
GROUP BY DATEPART(HOUR, TRY_CAST(Time_stamp AS DATETIME2))
ORDER BY Total_events DESC, Total_invoices DESC;
GO