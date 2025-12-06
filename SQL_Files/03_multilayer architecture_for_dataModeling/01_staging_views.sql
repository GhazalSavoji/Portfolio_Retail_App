--******************************************
-- 01_staging_views.sql
-- Staging layer: creates views to clean and standardize raw tables.
-- Includes Sessions, Events, Invoices, and Devices.
--******************************************

--******************************************
-- 3.1 Staging Layer
--=====================================
-- Staging Sessions
CREATE OR ALTER VIEW Staging.Stg_Sessions AS
SELECT
    session_id,
    user_id,
    timestamp,
    ISNULL(session_duration_sec,0) AS session_duration_sec,
    CASE 
        WHEN battery_level < 0 THEN 0
        WHEN battery_level > 100 THEN 100
        ELSE battery_level
    END AS battery_level,
    ISNULL(memory_usage_mb,0) AS memory_usage_mb,
    push_enabled,
    CASE 
           WHEN LOWER(network_type) IN ('wifi','4g','5g') THEN LOWER(network_type)
        ELSE 'other'
    END AS network_type,
    ip_address
FROM Events.session;


-- Test Staging Sessions
SELECT TOP 10 * FROM Staging.Stg_Sessions;
SELECT COUNT(*) AS Stg_Sessions_Count FROM Staging.Stg_Sessions;
GO

--Create session staging with truncated seconds
CREATE OR ALTER VIEW Staging.Stg_Sessions_Minute AS
SELECT *,
       DATEADD(SECOND, -DATEPART(SECOND, timestamp), timestamp) AS timestamp_minute
FROM Staging.Stg_Sessions;
-- Test 
SELECT TOP 10 * FROM Staging.Stg_Sessions_Minute;
SELECT COUNT(*) AS Count FROM Staging.Stg_Sessions_Minute;
GO

--===============================================================
-- Staging Events
CREATE OR ALTER VIEW Staging.Stg_Events AS
SELECT
    event_type_id,
    event_type,
    event_target,
    TRY_CAST(event_value AS FLOAT) AS event_value,
    session_id,
    Invoice,
    Time_stamp,        
    user_id
FROM Events.event_types;
GO
----------- Staging.Stg_Events_Minute

CREATE OR ALTER VIEW Staging.Stg_Events_Minute AS
SELECT
    e.*,
    CASE
        WHEN TRY_CAST(e.Time_stamp AS DATETIME) IS NOT NULL
            THEN DATEADD(
                    SECOND,
                    -DATEPART(SECOND, TRY_CAST(e.Time_stamp AS DATETIME)),
                    TRY_CAST(e.Time_stamp AS DATETIME)
                 )
        ELSE NULL
    END AS Time_stamp_Minute,
    CASE
        WHEN TRY_CAST(e.Time_stamp AS DATETIME) IS NOT NULL
            THEN CAST(FORMAT(
                     DATEADD(
                        SECOND,
                        -DATEPART(SECOND, TRY_CAST(e.Time_stamp AS DATETIME)),
                        TRY_CAST(e.Time_stamp AS DATETIME)
                     ), 'yyyyMMddHHmm') AS BIGINT)
        ELSE NULL
    END AS timestamp_sk

FROM Staging.Stg_Events e;
GO
SELECT  FROM Staging.Stg_Events_Minute
SELECT COUNT(*) FROM Staging.Stg_Events_Minute

--================================================================
-- Staging Invoices 
CREATE OR ALTER VIEW Staging.Stg_Invoices AS
SELECT DISTINCT
    Invoice,
    Customer_ID,
    Country,
    InvoiceDate
FROM [Transaction].invoice_info;
GO

-- Minute-level staging view: 
CREATE OR ALTER VIEW Staging.Stg_Invoices_Minute AS
SELECT
    i.*,
   
    CASE
        WHEN TRY_CAST(i.InvoiceDate AS DATETIME) IS NOT NULL
            THEN DATEADD(
                    SECOND,
                    -DATEPART(SECOND, TRY_CAST(i.InvoiceDate AS DATETIME)),
                    TRY_CAST(i.InvoiceDate AS DATETIME)
                 )
        ELSE NULL
    END AS InvoiceDate_Minute,

    CASE
        WHEN TRY_CAST(i.InvoiceDate AS DATETIME) IS NOT NULL
            THEN CAST(FORMAT(
                     DATEADD(
                        SECOND,
                        -DATEPART(SECOND, TRY_CAST(i.InvoiceDate AS DATETIME)),
                        TRY_CAST(i.InvoiceDate AS DATETIME)
                     ), 'yyyyMMddHHmm') AS BIGINT)
        ELSE NULL
    END AS timestamp_sk
FROM Staging.Stg_Invoices i;
GO

SELECT * FROM Staging.Stg_Invoices_Minute;
SELECT COUNT(*) AS Count FROM Staging.Stg_Invoices_Minute;
GO
SELECT COUNT(*) FROM Staging.Stg_Invoices_Minute
WHERE 'Algeria' IN (Country)
--===============================================================
--Staging invoice items

CREATE OR ALTER VIEW Staging.Stg_Inovice_Items AS
SELECT
	ii.invoice,
	s.InvoiceItem_ID,
	s.StockCode,
	s.S_Description,
	TRY_CAST(s.Quantity AS FLOAT) AS Quantity,
    TRY_CAST(s.Price AS FLOAT) AS Price
FROM [Transaction].[sales_info] s
LEFT JOIN [Transaction].[invoice_to_items] ii
ON s.InvoiceItem_ID=ii.InvoiceItem_ID
GO
SELECT * FROM Staging.Stg_Inovice_Items;
SELECT COUNT(*) AS Count FROM Staging.Stg_Inovice_Items;

--===============================================================
-- Staging device
CREATE OR ALTER VIEW Staging.Stg_Device AS
SELECT
    device_id,
	screen_resolution,
    user_id,
    -- Clean app_version to pattern x.y or x.yy
    CASE 
        WHEN app_version LIKE '[0-9]%' AND app_version LIKE '%.%' 
             THEN LEFT(app_version, CHARINDEX('.', app_version) + 2)
        ELSE NULL
    END AS app_version_clean,

    -- Clean OS version: keep only major.minor
    CASE 
        WHEN device_os_version LIKE '[0-9]%.%' 
             THEN LEFT(device_os_version, CHARINDEX('.', device_os_version) + 1)
        ELSE NULL
    END AS device_os_version_clean,
	device_model,
    device_os,
    app_language
FROM [MobileAppRetail_DB2].Users.device;

-- Test Staging.Stg_Device
SELECT TOP 100 * FROM Staging.Stg_Device;
SELECT COUNT(*) AS Stg_Device_Count FROM Staging.Stg_Device;
GO
--===========================================
-- staging iso countries
CREATE TABLE Staging.Stg_ISO_Countries (
    country_name NVARCHAR(200)
	)
BULK INSERT Staging.Stg_ISO_Countries
FROM 'C:\TempTables\countries.csv'
WITH (
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',       -- one column
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',          -- UTF-8
    TABLOCK
);