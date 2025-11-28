--******************************************
-- 03_fact_tables.sql
-- Fact layer: creates fact tables and inserts data
-- Fact_Sessions, Fact_Events, Fact_Invoices, Fact_Invoice_Items
--******************************************

--=====================================
-- Fact_Sessions
CREATE TABLE Fact.Fact_Sessions (
    session_sk INT IDENTITY(1,1) PRIMARY KEY,
    session_id NVARCHAR(50) NOT NULL,
    user_sk INT NOT NULL,
    device_sk INT NULL,
    session_duration_sec INT,
    battery_level INT,
    memory_usage_mb INT,
    push_enabled BIT,
    network_type NVARCHAR(20),
    timestamp_sk BIGINT NULL
);
CREATE INDEX idx_fact_user_sk ON Fact.Fact_Sessions(user_sk);
CREATE INDEX idx_fact_device_sk ON Fact.Fact_Sessions(device_sk);
CREATE INDEX idx_fact_timestamp_sk ON Fact.Fact_Sessions(timestamp_sk);
CREATE INDEX idx_fact_session_id ON Fact.Fact_Sessions(session_id);
GO

INSERT INTO Fact.Fact_Sessions (
    session_id, user_sk, device_sk, session_duration_sec, battery_level,
    memory_usage_mb, push_enabled, network_type, timestamp_sk
)
SELECT
    s.session_id,
    u.user_sk,
    udm.device_sk,
    s.session_duration_sec,
    s.battery_level,
    s.memory_usage_mb,
    s.push_enabled,
    s.network_type,
    t.timestamp_sk
FROM Staging.Stg_Sessions_Minute s
JOIN Dim.Dim_User u 
    ON s.user_id = u.user_id
LEFT JOIN Dim.User_Device_map udm
    ON u.user_sk = udm.user_sk
LEFT JOIN Dim.Dim_Timestamp_Minute t
    ON s.timestamp_minute = t.full_datetime_minute;
GO
-- Test Fact Sessions
SELECT TOP 100 * FROM Fact.Fact_Sessions;
SELECT COUNT(*) AS Fact_Sessions_Count FROM Fact.Fact_Sessions;
--=====================================
-- Fact_Events
CREATE TABLE Fact.Fact_Events (
    event_sk INT IDENTITY(1,1) PRIMARY KEY,
    event_id NVARCHAR(50) NOT NULL,
    session_sk INT NULL,
    user_id NVARCHAR(50) NULL,
    Time_stamp DATETIME NOT NULL,
    timestamp_sk BIGINT NULL,
    event_type NVARCHAR(50) NULL,
    event_target NVARCHAR(50) NULL,
    event_value FLOAT NULL,
    Invoice NVARCHAR(50) NULL
);
CREATE INDEX idx_fact_events_session_sk ON Fact.Fact_Events(session_sk);
CREATE INDEX idx_fact_events_user_id ON Fact.Fact_Events(user_id);
CREATE INDEX idx_fact_events_timestamp_sk ON Fact.Fact_Events(timestamp_sk);
CREATE INDEX idx_fact_events_invoice ON Fact.Fact_Events(Invoice);
GO

INSERT INTO Fact.Fact_Events (
    event_id, session_sk, user_id, Time_stamp, timestamp_sk,
    event_type, event_target, event_value, Invoice
)
SELECT
    e.event_type_id,
    s.session_sk,
    e.user_id,
    e.Time_stamp,
    t.timestamp_sk,
    e.event_type,
    e.event_target,
    e.event_value,
    e.Invoice
FROM Staging.Stg_Events_Minute e
LEFT JOIN Fact.Fact_Sessions s
    ON e.session_id = s.session_id
LEFT JOIN Dim.Dim_Timestamp_Minute t
    ON t.full_datetime_minute = e.Time_stamp_Minute;
GO
--Test Fact_Events:
SELECT TOP 100 * FROM Fact.Fact_Events;
SELECT COUNT(*) AS Fact_Events_Count FROM Fact.Fact_Events;
--=====================================
-- Fact_Invoices
CREATE TABLE Fact.Fact_Invoices (
    invoice_sk INT IDENTITY(1,1) PRIMARY KEY,
    invoice_number NVARCHAR(50) NOT NULL,
    user_sk INT NOT NULL,
    invoice_date DATETIME NOT NULL,
    location_country NVARCHAR(150) NULL,
    timestamp_sk BIGINT NULL
);
GO

INSERT INTO Fact.Fact_Invoices (
    invoice_number, user_sk, invoice_date, location_country, timestamp_sk
)
SELECT
    i.Invoice,
    u.user_sk,
    i.InvoiceDate,
    u.location_country,
    t.timestamp_sk
FROM Staging.Stg_Invoices_User_Minute i
JOIN Dim.Dim_User u
    ON i.user_id = u.user_id
JOIN Dim.Dim_Timestamp t
    ON t.full_datetime = i.InvoiceDate_Minute;
GO
-- Test Fact Invoice
SELECT TOP 100 * FROM Fact.Fact_Invoices;
SELECT COUNT(*) AS Fact_Invoices_Count FROM Fact.Fact_Invoices;
--=====================================
-- Fact_Invoice_Items
CREATE TABLE Fact.Fact_Invoice_Items (
    invoice_item_sk INT IDENTITY(1,1) PRIMARY KEY,
    invoice_item_id NVARCHAR(50) NOT NULL,
    invoice_sk INT NOT NULL,
    stock_sk INT NOT NULL,
    quantity FLOAT,
    is_return BIT,
    price FLOAT,
    description NVARCHAR(200),
    stock_code NVARCHAR(50)
);
GO

INSERT INTO Fact.Fact_Invoice_Items (
    invoice_item_id, invoice_sk, stock_sk, quantity, is_return, price, description, stock_code
)
SELECT
    ii.InvoiceItem_ID,
    fi.invoice_sk,
    s.stock_sk,
    ii.Quantity,
    0, -- assuming no return info
    ii.Price,
    ii.S_Description,
    ii.StockCode
FROM Staging.Stg_Invoices_With_User ii
JOIN Fact.Fact_Invoices fi
    ON ii.Invoice = fi.invoice_number
JOIN Dim.Dim_StockCodes s
    ON ii.StockCode = s.StockCode;
GO
-- Test Fact Invoice_Items
SELECT TOP 100 * FROM Fact.Fact_Invoice_Items;
SELECT COUNT(*) AS Fact_Invoice_Items_Count FROM Fact.Fact_Invoice_Items;