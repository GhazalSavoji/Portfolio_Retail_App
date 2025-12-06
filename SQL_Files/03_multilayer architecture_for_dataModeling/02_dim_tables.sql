--=====================================================
--Dim location
CREATE TABLE Dim.Dim_Location (
    location_sk INT IDENTITY(1,1) PRIMARY KEY,
    country_name NVARCHAR(200)
);

CREATE INDEX idx_dim_location_name ON Dim.Dim_Location(country_name);
INSERT INTO Dim.Dim_Location (
    country_name
)
SELECT DISTINCT
    country_name
FROM Staging.Stg_ISO_Countries
WHERE country_name IS NOT NULL;

--test
SELECT COUNT(*) FROM Dim.Dim_Location
SELECT * FROM Dim.Dim_Location

--===============================================
-- Dim User (SCD Type 2)
CREATE OR ALTER VIEW Dim.Dim_User AS
SELECT
    ROW_NUMBER() OVER(ORDER BY u.user_id) AS user_sk,
    u.user_id,
    IIF(u.user_age < 15, 15, u.user_age) AS user_age,
    u.is_subscribed,
    u.location_country,           
    GETDATE() AS start_date_scd,
    '9999-12-31' AS end_date_scd,
    1 AS is_current_scd
FROM [MobileAppRetail_DB2].[Users].[user] u
 

-- Test Dim User
SELECT TOP 100 * FROM Dim.Dim_User;
SELECT COUNT(*) AS Dim_User_Count FROM Dim.Dim_User;
SELECT COUNT(location_sk) AS lCount FROM Dim.Dim_User WHERE location_sk IS NOT NULL;

GO
-- Bridge table between user and location
CREATE TABLE Dim.User_Location_Map (
    user_id NVARCHAR(50) PRIMARY KEY,
    location_sk INT
);

-- Populate it by joining Dim_User to Dim_Location
INSERT INTO Dim.User_Location_Map (user_id, location_sk)
SELECT 
    user_id,
    location_sk
FROM Dim.Dim_User 

--test
SELECT TOP 100 * FROM Dim.User_Location_Map;
SELECT COUNT(*) AS Count_DIM FROM Dim.User_Location_Map;

--=====================================================
-- Dim Device (SCD Type 1)
CREATE TABLE Dim.Dim_Devices (
    device_sk INT IDENTITY(1,1) PRIMARY KEY,
    device_id NVARCHAR(50) UNIQUE,
    user_id NVARCHAR(50),
    device_os NVARCHAR(50),
    app_version NVARCHAR(10),
    device_os_version NVARCHAR(10),
    device_model NVARCHAR(100),
    screen_resolution NVARCHAR(20),
    app_language NVARCHAR(10),
    last_updated_scd DATETIME DEFAULT GETDATE()
);
INSERT INTO Dim.Dim_Devices (
    device_id, user_id, device_os, app_version, device_os_version,
    device_model, screen_resolution, app_language
)
SELECT 
    device_id,
    user_id,
    device_os,
    app_version_clean,
    device_os_version_clean,
    device_model,
    screen_resolution,
    app_language
FROM Staging.Stg_Device;


--For better time performance, a more simple table for joing in dim-divece
CREATE TABLE Dim.User_Device_map (
    user_sk INT NOT NULL,
    device_sk INT NOT NULL,
    PRIMARY KEY (user_sk, device_sk)
);
CREATE INDEX idx_user_sk ON Dim.User_Device_map(user_sk);
INSERT INTO Dim.User_Device_map (user_sk, device_sk)
SELECT 
    u.user_sk,
    d.device_sk
FROM Dim.Dim_Devices d
JOIN Dim.Dim_User u 
    ON d.user_id = u.user_id;

-- Test Dim Device
SELECT TOP 100 * FROM Dim.Dim_Devices;
SELECT COUNT(*) AS Dim_Device_Count FROM Dim.Dim_Devices;
SELECT COUNT(*) AS User_Device_map_Count FROM Dim.User_Device_map;

GO

--=====================================================
-- Dim Timestamp (SCD Type 0)
CREATE OR ALTER VIEW Dim.Dim_Timestamp AS
SELECT DISTINCT
    CAST(FORMAT(full_datetime,'yyyyMMddHHmm') AS BIGINT) AS timestamp_sk,
    full_datetime,
    CAST(full_datetime AS DATE) AS [date],
	-- Limit year to max 2025
    CASE 
        WHEN YEAR(full_datetime) > 2025 THEN 2025
        ELSE YEAR(full_datetime)
    END AS [year],
    MONTH(full_datetime) AS [month],
    DAY(full_datetime) AS [day],
    DATEPART(HOUR, full_datetime) AS [hour],
    DATEPART(MINUTE, full_datetime) AS [minute],
    DATEPART(WEEKDAY, full_datetime) AS day_of_week,
    CASE WHEN DATEPART(WEEKDAY, full_datetime) IN (1,7) THEN 1 ELSE 0 END AS is_weekend
FROM (
    SELECT timestamp AS full_datetime FROM Staging.Stg_Sessions
    UNION
    SELECT TRY_CAST(InvoiceDate AS DATETIME) AS full_datetime 
    FROM Staging.Stg_Invoices
    WHERE TRY_CAST(InvoiceDate AS DATETIME) IS NOT NULL
    UNION
    SELECT TRY_CAST(Time_stamp AS DATETIME) AS full_datetime 
    FROM Staging.Stg_Events
) AS combined
WHERE full_datetime IS NOT NULL;
---------------- 
SELECT * FROM Dim.Dim_Timestamp
SELECT COUNT(*) FROM Dim.Dim_Timestamp

--------------
--Clean duplicates
CREATE OR ALTER VIEW Dim.Dim_Timestamp_Clean AS
WITH RankedTimestamps AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY timestamp_sk ORDER BY full_datetime DESC) AS rn
    FROM Dim.Dim_Timestamp
)
SELECT *
FROM RankedTimestamps
WHERE rn = 1;

---- Clean nulls
CREATE OR ALTER VIEW Dim.Dim_Timestamp_Clean_NoNulls AS
SELECT *
FROM Dim.Dim_Timestamp_Clean
WHERE timestamp_sk IS NOT NULL
  AND full_datetime IS NOT NULL;

  --Precompute minute-truncated timestamps
CREATE OR ALTER VIEW Dim.Dim_Timestamp_Minute AS
SELECT 
    timestamp_sk,
    DATEADD(SECOND, -DATEPART(SECOND, full_datetime), full_datetime) AS full_datetime_minute,
    [date], [year], [month], [day], [hour], [minute], day_of_week, is_weekend
FROM Dim.Dim_Timestamp_Clean_NoNulls;
--- Check to test
SELECT * FROM Dim.Dim_Timestamp
SELECT * FROM Dim.Dim_Timestamp_Minute
SELECT * FROM Dim.Dim_Timestamp_Clean
SELECT * FROM Dim.Dim_Timestamp_Clean_NoNulls
---Count to test
SELECT 
    'Dim_Timestamp' AS ViewName,
    COUNT(*) AS RecordCount
FROM Dim.Dim_Timestamp

UNION ALL

SELECT 
    'Dim_Timestamp_Clean' AS ViewName,
    COUNT(*) AS RecordCount
FROM Dim.Dim_Timestamp_Clean

UNION ALL

SELECT 
    'Dim_Timestamp_Clean_NoNulls' AS ViewName,
    COUNT(*) AS RecordCount
FROM Dim.Dim_Timestamp_Clean_NoNulls

UNION ALL

SELECT 
    'Dim_Timestamp_Minute' AS ViewName,
    COUNT(*) AS RecordCount
FROM Dim.Dim_Timestamp_Minute

ORDER BY ViewName;
--=====================================================
-- Dim StockCodes (SCD Type 1)
CREATE OR ALTER VIEW Dim.Dim_StockCodes AS
SELECT
    ROW_NUMBER() OVER(ORDER BY StockCode) AS stock_sk,
    StockCode
FROM [Transaction].sales_info
GROUP BY StockCode;
-- Test Dim StockCodes
SELECT TOP 100 * FROM Dim.Dim_StockCodes;
SELECT COUNT(*) AS Dim_Dim_StockCodes FROM Dim.Dim_StockCodes;
GO
