-- ***********************************************************************************
-- FILE: 04_create_event_types_table.sql
-- DESCRIPTION: Create Events.[event_types] table, BULK INSERT, data cleaning, FK constraints
-- ***********************************************************************************

CREATE TABLE Events.[event_types] (
    event_type_id NVARCHAR(20) PRIMARY KEY,
    Time_stamp NVARCHAR(50),
    session_id NVARCHAR(20),
    user_id NVARCHAR(20),
    event_type NVARCHAR(50),
    event_target NVARCHAR(50),
    event_value NVARCHAR(50),
    Invoice NVARCHAR(20) NULL,
    CONSTRAINT FK_event_types_session FOREIGN KEY (session_id) REFERENCES Events.[session](session_id),
    CONSTRAINT FK_event_types_user FOREIGN KEY (user_id) REFERENCES Users.[user](user_id)
);
GO

-- Insert from CSV
BULK INSERT Events.[event_types]
FROM 'C:\TempTables\events_types.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Data cleaning
UPDATE Events.[event_types]
SET Time_stamp = CASE WHEN Time_stamp LIKE '____-__-__T__:__:__' THEN Time_stamp ELSE NULL END;

UPDATE Events.[event_types]
SET event_value = CASE WHEN TRY_CAST(event_value AS FLOAT) IS NOT NULL THEN event_value ELSE NULL END;
GO
