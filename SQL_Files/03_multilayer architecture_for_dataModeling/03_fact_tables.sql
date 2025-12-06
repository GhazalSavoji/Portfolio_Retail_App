--******************************************
-- 03_fact_tables.sql
-- Fact layer: creates fact tables and inserts data
-- Fact_Sessions, Fact_Events, Fact_Invoices, Fact_Invoice_Items
--******************************************

--=====================================
-- Create Fact_Sessions, physical table
CREATE TABLE Fact.Fact_Sessions (
    session_sk INT IDENTITY(1,1) PRIMARY KEY,   -- Surrogate key  
    user_sk INT NOT NULL,                        
    device_sk INT NULL,   
	timestamp_sk BIGINT NULL,     
	location_sk INT,
	session_id NVARCHAR(50) NOT NULL,
    session_duration_sec INT,
    battery_level INT,
    memory_usage_mb INT,
    push_enabled BIT,
    network_type NVARCHAR(20)
);
-- Indexes for faster joins
CREATE INDEX idx_fact_user_sk ON Fact.Fact_Sessions(user_sk);
CREATE INDEX idx_fact_device_sk ON Fact.Fact_Sessions(device_sk);
CREATE INDEX idx_fact_location_sk ON Fact.Fact_Sessions(location_sk);
CREATE INDEX idx_fact_timestamp_sk ON Fact.Fact_Sessions(timestamp_sk);
CREATE INDEX idx_fact_session_id ON Fact.Fact_Sessions(session_id);
INSERT INTO Fact.Fact_Sessions (  
    user_sk,
    device_sk,
	timestamp_sk,
    location_sk,
	session_id,
    session_duration_sec,
    battery_level,
    memory_usage_mb,
    push_enabled,
    network_type  
)
SELECT
    u.user_sk,
    udm.device_sk,
	t.timestamp_sk,
    ulm.location_sk,   
	s.session_id,
    s.session_duration_sec,
    s.battery_level,
    s.memory_usage_mb,
    s.push_enabled,
    s.network_type  
FROM Staging.Stg_Sessions_Minute s
LEFT JOIN Dim.Dim_User u 
    ON s.user_id = u.user_id
LEFT JOIN Dim.User_Device_map udm
    ON u.user_sk = udm.user_sk
LEFT JOIN Dim.User_Location_Map ulm
    ON u.user_id = ulm.user_id
LEFT JOIN Dim.Dim_Timestamp_Minute t
    ON s.timestamp_minute IS NOT NULL 
    AND t.full_datetime_minute IS NOT NULL
    AND s.timestamp_minute = t.full_datetime_minute;
GO

--==========CHECK 1
-- Counts at Events table
SELECT 
    COUNT(*) AS TotalSessions_Events,
    COUNT(u.user_id) AS SessionsWithUser,
    COUNT(u.location_country) AS SessionsWithCountry
FROM [EVENTS].[session] s
LEFT JOIN [Users].[user] u ON s.user_id = u.user_id;

-- Counts at Events Fact table
SELECT 
    COUNT(*) AS TotalSessions_Fact,
    COUNT(user_sk) AS SessionsWithUserSK,
    COUNT(location_sk) AS SessionsWithLocationSK
FROM Fact.Fact_Sessions;
--Check 2
SELECT 
    COUNT(*) AS TotalRecords,
    COUNT(timestamp_sk) AS RecordsWithTimestamp,
    SUM(CASE WHEN timestamp_sk IS NULL THEN 1 ELSE 0 END) AS RecordsWithoutTimestamp,
    ROUND(100.0 * SUM(CASE WHEN timestamp_sk IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS PercentageNull
FROM Fact.Fact_Sessions;
--check 3
SELECT 
    s.session_id,
    s.timestamp_minute AS Staging_Timestamp,
    t.full_datetime_minute AS Dim_Timestamp,
    f.timestamp_sk,
    CASE 
        WHEN t.full_datetime_minute = s.timestamp_minute THEN 'Match'
        ELSE 'Mismatch' 
    END AS Status
FROM Staging.Stg_Sessions_Minute s
LEFT JOIN Fact.Fact_Sessions f ON s.session_id = f.session_id
LEFT JOIN Dim.Dim_Timestamp_Minute t ON f.timestamp_sk = t.timestamp_sk
WHERE s.timestamp_minute IS NOT NULL
ORDER BY s.timestamp_minute
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


--=====================================
-- Fact_Events:
--=====================================
-- create a physical table
CREATE TABLE Fact.Fact_Events (
    event_sk INT IDENTITY(1,1) PRIMARY KEY,  
    event_id NVARCHAR(50) NOT NULL,          
    session_sk INT NULL,                     
    user_id NVARCHAR(50) NULL,   
    --Time_stamp DATETIME ,             
    timestamp_sk BIGINT NULL,                 
    event_type NVARCHAR(50) NULL,
    event_target NVARCHAR(50) NULL,
    event_value FLOAT NULL,
    Invoice NVARCHAR(50) NULL,
	location_sk INT

);

-- Indexes for performance
CREATE INDEX idx_fact_events_session_sk ON Fact.Fact_Events(session_sk);
CREATE INDEX idx_fact_events_location_sk ON Fact.Fact_Events(location_sk);
CREATE INDEX idx_fact_events_user_id ON Fact.Fact_Events(user_id);
CREATE INDEX idx_fact_events_timestamp_sk ON Fact.Fact_Events(timestamp_sk);
CREATE INDEX idx_fact_events_invoice ON Fact.Fact_Events(Invoice);

-- Insert into Fact.Fact_Events with location_sk
INSERT INTO Fact.Fact_Events (
	event_id,
    session_sk,
    user_id,
    --Time_stamp,
    timestamp_sk,
    event_type,
    event_target,
    event_value,
    Invoice,
	location_sk
)
SELECT
    e.event_type_id,
    s.session_sk,
    e.user_id,
    --e.Time_stamp_Minute,
    t.timestamp_sk,
    e.event_type,
    e.event_target,
    e.event_value,
    e.Invoice,
	ulm.location_sk  
FROM Staging.Stg_Events_Minute e
LEFT JOIN Fact.Fact_Sessions s
    ON e.session_id = s.session_id
LEFT JOIN Dim.Dim_Timestamp_Minute t
    ON t.full_datetime_minute = e.Time_stamp_Minute
LEFT JOIN Dim.User_Location_Map ulm
    ON e.user_id = ulm.user_id;


--Test:
SELECT TOP 100 * FROM Fact.Fact_Events;
SELECT COUNT(*) AS Fact_Events_Count FROM Fact.Fact_Events;
--======================================
-- A bridge table to relate Event and Session Facts
CREATE TABLE SessionEvent_Bridge (
    session_sk INT,
    event_sk INT
);
INSERT INTO SessionEvent_Bridge (session_sk, event_sk)
SELECT 
    s.session_sk,
    e.event_sk
FROM Fact.Fact_Sessions s
INNER JOIN Fact.Fact_Events e
    ON s.session_sk = e.session_sk;

--=====================================
-- Fact Invoices
--=====================================
-- A bridge table between events and invoices
CREATE TABLE InvoiceEventSession_Bridge (
    Invoice NVARCHAR(50) NOT NULL,
	session_sk INT NOT NULL,
    event_sk INT NOT NULL
);

-- Insert
INSERT INTO InvoiceEventSession_Bridge (Invoice, session_sk, event_sk)
SELECT
    i.Invoice,
	e.session_sk,
    e.event_sk
FROM Staging.Stg_Invoices_Minute i
JOIN Fact.Fact_Events e
    ON i.Invoice = e.Invoice;
SELECT COUNT(*) FROM InvoiceEventSession_Bridge

-- Create a physical table for Invoice fact
CREATE TABLE Fact.Fact_Invoices (
    invoice_sk INT IDENTITY(1,1) PRIMARY KEY,  
    invoice_number NVARCHAR(50) NOT NULL,      
    user_sk INT NOT NULL,                       
    location_sk INT NULL, 
	session_sk INT NULL,
	event_sk INT NULL,
    timestamp_sk BIGINT NULL                    
);
-- Fact_Invoices insert using location_sk
INSERT INTO Fact.Fact_Invoices (
    invoice_number,
    user_sk,
    location_sk,
	session_sk,
	event_sk,
    timestamp_sk
)
SELECT
    i.Invoice,
    u.user_sk,
    l.location_sk,
	b.session_sk,
	b.event_sk,
	t.timestamp_sk
FROM Staging.Stg_Invoices_Minute i
LEFT JOIN Dim.Dim_User u
    ON i.Customer_ID = u.user_id
LEFT JOIN Dim.Dim_Location l
	ON l.country_name = i.Country
LEFT JOIN Dim.Dim_Timestamp_Minute t
ON t.full_datetime_minute = i.InvoiceDate_Minute
LEFT JOIN InvoiceEventSession_Bridge b
ON  b.Invoice = i.Invoice

SELECT COUNT( *) FROM Fact.Fact_Invoices
WHERE location_sk =238
SELECT COUNT( *) FROM Staging.Stg_Invoices i
WHERE 'United States' IN (Country)

-- Test Fact Invoice
SELECT TOP 100 * FROM Fact.Fact_Invoices;
SELECT COUNT(*) AS Fact_Invoices_Count FROM Fact.Fact_Invoices;


--=============================================
-- Fact Invoice Items
--=============================================
CREATE TABLE Fact.Fact_Invoice_Items (
    invoice_item_sk INT IDENTITY(1,1) PRIMARY KEY,
    invoice_sk INT NOT NULL,
    stock_sk INT NOT NULL,
    quantity FLOAT,
    price FLOAT,
    description NVARCHAR(200)
);

INSERT INTO Fact.Fact_Invoice_Items (
    invoice_sk,
    stock_sk,
    quantity,
    price,
    description
)
SELECT
    fi.invoice_sk,
    s.stock_sk,
    ii.Quantity,
    ii.Price,
    ii.S_Description
FROM Staging.Stg_Inovice_Items ii
JOIN Fact.Fact_Invoices fi
    ON ii.Invoice = fi.invoice_number
JOIN Dim.Dim_StockCodes s
    ON ii.StockCode = s.StockCode;


SELECT TOP 100 * FROM Fact.Fact_Invoice_Items;
SELECT COUNT(*) AS Fact_Invoice_Items_Count FROM Fact.Fact_Invoice_Items;
