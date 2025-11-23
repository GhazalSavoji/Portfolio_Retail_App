-- ***********************************************************************************
-- FILE: 03_create_session_table.sql
-- DESCRIPTION: Create Events.[session] table, BULK INSERT, clean data, type conversion
-- ***********************************************************************************

CREATE TABLE Events.[session] (
    session_id NVARCHAR(20) PRIMARY KEY,
    user_id NVARCHAR(20) NOT NULL,
    Time_stamp NVARCHAR(45),
    session_duration_sec NVARCHAR(30),
    ip_address NVARCHAR(45),
    network_type NVARCHAR(30),
    battery_level NVARCHAR(30),
    memory_usage_mb NVARCHAR(30),
    push_enabled NVARCHAR(20),
    CONSTRAINT FK_session_user FOREIGN KEY (user_id) REFERENCES Users.[user](user_id) ON DELETE CASCADE
);
GO

-- Insert from CSV
BULK INSERT Events.[session]
FROM 'C:\TempTables\sessions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Data cleaning & type conversion
UPDATE Events.[session]
SET session_duration_sec = CASE WHEN TRY_CAST(session_duration_sec AS INT) IS NOT NULL THEN session_duration_sec ELSE NULL END;

UPDATE Events.[session]
SET battery_level = CASE WHEN TRY_CAST(battery_level AS INT) IS NOT NULL THEN battery_level ELSE NULL END;

UPDATE Events.[session]
SET memory_usage_mb = CASE WHEN TRY_CAST(memory_usage_mb AS INT) IS NOT NULL THEN memory_usage_mb ELSE NULL END;

UPDATE Events.[session]
SET push_enabled = 
    CASE 
        WHEN LOWER(push_enabled) IN ('true') THEN 1
        WHEN LOWER(push_enabled) IN ('false') THEN 0
        ELSE NULL
    END;

UPDATE Events.[session]
SET Time_stamp = CASE WHEN Time_stamp LIKE '____-__-__T__:__:__' THEN Time_stamp ELSE NULL END;
GO

-- Add temp columns with correct data types
ALTER TABLE Events.[session] 
ADD timestamp_new DATETIME2,
    session_duration_sec_new INT,
    battery_level_new INT,
    memory_usage_mb_new INT,
    push_enabled_new BIT;
GO

-- Copy data to new columns
UPDATE Events.[session]
SET
    timestamp_new = CASE WHEN ISDATE(Time_stamp) = 1 THEN CAST(Time_stamp AS DATETIME2) ELSE NULL END,
    session_duration_sec_new = CAST(session_duration_sec AS INT),
    battery_level_new = CAST(battery_level AS INT),
    memory_usage_mb_new = CAST(memory_usage_mb AS INT),
    push_enabled_new = CASE WHEN LOWER(push_enabled) IN ('true') THEN 1 WHEN LOWER(push_enabled) IN ('false') THEN 0 ELSE NULL END;
GO

-- Drop old columns and rename new ones
ALTER TABLE Events.[session] DROP COLUMN Time_stamp, session_duration_sec, battery_level, memory_usage_mb, push_enabled;
GO

EXEC sp_rename 'Events.[session].timestamp_new', 'timestamp', 'COLUMN';
EXEC sp_rename 'Events.[session].session_duration_sec_new', 'session_duration_sec', 'COLUMN';
EXEC sp_rename 'Events.[session].battery_level_new', 'battery_level', 'COLUMN';
EXEC sp_rename 'Events.[session].memory_usage_mb_new', 'memory_usage_mb', 'COLUMN';
EXEC sp_rename 'Events.[session].push_enabled_new', 'push_enabled', 'COLUMN';
GO
