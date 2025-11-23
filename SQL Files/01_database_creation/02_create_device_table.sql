-- ***********************************************************************************
-- FILE: 02_create_device_table.sql
-- DESCRIPTION: Create Users.[device] table, BULK INSERT, foreign key to user
-- ***********************************************************************************

CREATE TABLE Users.[device] (
    device_id NVARCHAR(50) PRIMARY KEY,
    device_os NVARCHAR(50),
    device_os_version NVARCHAR(50),
    device_model NVARCHAR(50),
    screen_resolution NVARCHAR(50),
    app_language NVARCHAR(10),
    app_version NVARCHAR(20),
    user_id NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_device_user FOREIGN KEY (user_id) REFERENCES Users.[user](user_id) ON DELETE CASCADE
);
GO

-- Insert from CSV
BULK INSERT Users.[device]
FROM 'C:\TempTables\device.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO
