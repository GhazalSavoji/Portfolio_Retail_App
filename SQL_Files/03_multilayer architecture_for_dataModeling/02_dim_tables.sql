--******************************************
-- 02_dim_tables.sql
-- Dimension layer: creates dimension tables and SCD logic
-- Dim_User, Dim_Devices, Dim_Timestamp, Dim_Event_Type, Dim_StockCodes
--******************************************

--=====================================
-- Dim User (SCD Type 2)
CREATE OR ALTER VIEW Dim.Dim_User AS
SELECT
    ROW_NUMBER() OVER(ORDER BY user_id) AS user_sk,
    user_id,
    user_age,
    is_subscribed,
    location_city,
    location_country,
    GETDATE() AS start_date_scd,
    '9999-12-31' AS end_date_scd,
    1 AS is_current_scd
FROM [MobileAppRetail_DB].[Users].[user];
GO
-- Test Dim User
SELECT TOP 100 * FROM Dim.Dim_User;
SELECT COUNT(*) AS Dim_User_Count FROM Dim.Dim_User;
GO

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
GO

-- Map users to devices
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
GO
-- Test Dim Device
SELECT TOP 100 * FROM Dim.Dim_Devices;
SELECT COUNT(*) AS Dim_Device_Count FROM Dim.Dim_Devices;
SELECT COUNT(*) AS User_Device_map_Count FROM Dim.User_Device_map;
GO
-- Dim Timestamp (SCD Type 0)
CREATE OR ALTER VIEW Dim.Dim_Timestamp AS
SELECT DISTINCT
    CAST(FORMAT(timestamp,'yyyyMMddHHmm') AS BIGINT) AS timestamp_sk,
    timestamp AS full_datetime,
    CAST(timestamp AS DATE) AS [date],
    YEAR(timestamp) AS [year],
    MONTH(timestamp) AS [month],
    DAY(timestamp) AS [day],
    DATEPART(HOUR,timestamp) AS [hour],
    DATEPART(MINUTE,timestamp) AS [minute],
    DATEPART(WEEKDAY,timestamp) AS day_of_week,
    CASE WHEN DATEPART(WEEKDAY,timestamp) IN (1,7) THEN 1 ELSE 0 END AS is_weekend
FROM (
    SELECT timestamp FROM Staging.Stg_Sessions
    UNION
    SELECT CAST(InvoiceDate AS DATETIME) AS timestamp
    FROM Staging.Stg_Invoices_UserSession
) AS combined;
GO
-- Dim Timestamp truncated to minute for faster joins
CREATE OR ALTER VIEW Dim.Dim_Timestamp_Minute AS
SELECT DISTINCT
    CAST(FORMAT(full_datetime,'yyyyMMddHHmm') AS BIGINT) AS timestamp_sk,
    DATEADD(SECOND, -DATEPART(SECOND, full_datetime), full_datetime) AS full_datetime_minute
FROM Dim.Dim_Timestamp;
GO
-- Dim StockCodes (SCD Type 1)
CREATE OR ALTER VIEW Dim.Dim_StockCodes AS
SELECT
    ROW_NUMBER() OVER(ORDER BY StockCode) AS stock_sk,
    StockCode
FROM [Transaction].sales_info
GROUP BY StockCode;
GO
-- Test Dim StockCodes
SELECT TOP 100 * FROM Dim.Dim_StockCodes;
SELECT COUNT(*) AS Dim_Dim_StockCodes FROM Dim.Dim_StockCodes;
GO