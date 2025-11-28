--******************************************
-- 01_staging_views.sql
-- Staging layer: creates views to clean and standardize raw tables.
-- Includes Sessions, Events, Invoices, and Devices.
--******************************************

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
GO

-- Truncate seconds for session timestamps
CREATE OR ALTER VIEW Staging.Stg_Sessions_Minute AS
SELECT *,
       DATEADD(SECOND, -DATEPART(SECOND, timestamp), timestamp) AS timestamp_minute
FROM Staging.Stg_Sessions;
GO

-- Test Staging Sessions
SELECT TOP 10 * FROM Staging.Stg_Sessions;
SELECT COUNT(*) AS Stg_Sessions_Count FROM Staging.Stg_Sessions;
GO
--=====================================
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
    user_id,
    CAST(FORMAT(TRY_CAST(Time_stamp AS DATETIME),'yyyyMMddHHmm') AS BIGINT) AS timestamp_sk
FROM Events.event_types
WHERE TRY_CAST(Time_stamp AS DATETIME) IS NOT NULL;
GO

-- Test Staging Events
SELECT TOP 10 * FROM Staging.Stg_Events;
SELECT COUNT(*) AS Stg_Events_Count FROM Staging.Stg_Events;
GO

-- Truncate seconds for events
CREATE OR ALTER VIEW Staging.Stg_Events_Minute AS
SELECT *,
       DATEADD(SECOND, -DATEPART(SECOND, Time_stamp), CAST(Time_stamp AS DATETIME)) AS Time_stamp_Minute
FROM Staging.Stg_Events
WHERE TRY_CAST(Time_stamp AS DATETIME) IS NOT NULL;
GO

--=====================================
-- Staging Invoices
CREATE OR ALTER VIEW Staging.Stg_Invoices_UserSession AS
SELECT DISTINCT
    e.Invoice,
    e.user_id,
    e.session_id,     
    s.InvoiceDate,
    s.Country
FROM Events.event_types e
JOIN [Transaction].invoice_info s
    ON e.Invoice = s.Invoice
WHERE e.Invoice IS NOT NULL;
GO

CREATE OR ALTER VIEW Staging.Stg_Invoices_User_Minute AS
SELECT
    Invoice,
    user_id,
    InvoiceDate,
    DATEADD(SECOND, -DATEPART(SECOND, InvoiceDate), InvoiceDate) AS InvoiceDate_Minute
FROM Staging.Stg_Invoices_UserSession;
GO
-- Test
SELECT TOP 10 * FROM Staging.Stg_Invoices_UserSession;
SELECT COUNT(*) AS Count FROM Staging.Stg_Invoices_UserSession;
GO
-- Map invoices to user_id
CREATE OR ALTER VIEW Staging.Invoice_User_Map AS
SELECT DISTINCT
    e.Invoice,
    e.user_id
FROM Staging.Stg_Events e
WHERE e.Invoice IS NOT NULL;
GO

-- Updated Staging Invoices with user_id
CREATE OR ALTER VIEW Staging.Stg_Invoices_With_User AS
SELECT
    i.Invoice,
    i.InvoiceItem_ID,
    i.StockCode,
    i.Quantity,
    i.Price,
    i.S_Description,
    i.InvoiceDate,
    i.Country,
    uim.user_id
FROM Staging.Stg_Invoices i
LEFT JOIN Staging.Invoice_User_Map uim
    ON i.Invoice = uim.Invoice;
GO

-- Map invoices to user_id from events (buyers)
CREATE OR ALTER VIEW Staging.Invoice_User_Map AS
SELECT DISTINCT
    e.Invoice,
    e.user_id
FROM Staging.Stg_Events e
WHERE e.Invoice IS NOT NULL;

-- Test:
SELECT TOP 10 * FROM Staging.Invoice_User_Map;
SELECT COUNT(*) AS Count FROM Staging.Invoice_User_Map;
GO

--=====================================
-- Staging Device
CREATE OR ALTER VIEW Staging.Stg_Device AS
SELECT
    device_id,
	screen_resolution,
    user_id,
    CASE 
        WHEN app_version LIKE '[0-9]%' AND app_version LIKE '%.%' 
             THEN LEFT(app_version, CHARINDEX('.', app_version) + 2)
        ELSE NULL
    END AS app_version_clean,
    CASE 
        WHEN device_os_version LIKE '[0-9]%.%' 
             THEN LEFT(device_os_version, CHARINDEX('.', device_os_version) + 1)
        ELSE NULL
    END AS device_os_version_clean,
	device_model,
    device_os,
    app_language
FROM [MobileAppRetail_DB].Users.device;
GO

-- Test Staging.Stg_Device
SELECT TOP 100 * FROM Staging.Stg_Device;
SELECT COUNT(*) AS Stg_Device_Count FROM Staging.Stg_Device;
GO