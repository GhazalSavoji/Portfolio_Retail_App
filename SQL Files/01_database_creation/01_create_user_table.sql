-- ***********************************************************************************
-- FILE: 01_create_user_table.sql
-- DESCRIPTION: Create Users.[user] table, BULK INSERT from CSV, clean data, type conversion
-- ***********************************************************************************

CREATE TABLE Users.[user] (
    user_id NVARCHAR(50) PRIMARY KEY,
	location_country NVARCHAR(80),
	location_city NVARCHAR(50),
	is_subscribed NVARCHAR(50),
    user_age NVARCHAR(50),
	phone_number NVARCHAR(150)  
);
GO

-- Insert from CSV
BULK INSERT Users.[user]
FROM 'C:\TempTables\users.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Data cleaning
UPDATE Users.[user]
SET is_subscribed = 
    CASE 
        WHEN LOWER(is_subscribed) IN ('true', 'false') THEN is_subscribed      
        WHEN LOWER(LEFT(is_subscribed, 1)) = 't' THEN 'True'    
        WHEN LOWER(LEFT(is_subscribed, 1)) = 'f' THEN 'False'   
        ELSE NULL
    END;
GO

UPDATE Users.[user]
SET user_age = 
    CASE 
        WHEN ISNUMERIC(user_age) = 1 THEN user_age
        ELSE NULL
    END;
GO

-- Data type conversion using temporary columns
ALTER TABLE Users.[user] 
ADD user_id_new NVARCHAR(20),
    user_age_new INT,
    is_subscribed_new BIT;
GO

UPDATE Users.[user]
SET
    user_id_new = CAST(user_id AS NVARCHAR(20)),
    user_age_new = CAST(user_age AS INT),
    is_subscribed_new = CASE
        WHEN LOWER(is_subscribed) IN ('true', 'yes', '1') THEN 1
        WHEN LOWER(is_subscribed) IN ('false', 'no', '0') THEN 0
        ELSE 0
    END;
GO

-- Drop old columns and rename new ones
ALTER TABLE Users.[user] DROP COLUMN user_id, user_age, is_subscribed;
GO

EXEC sp_rename 'Users.[user].user_id_new', 'user_id', 'COLUMN';
EXEC sp_rename 'Users.[user].user_age_new', 'user_age', 'COLUMN';
EXEC sp_rename 'Users.[user].is_subscribed_new', 'is_subscribed', 'COLUMN';
GO

ALTER TABLE Users.[user] ALTER COLUMN user_id NVARCHAR(20) NOT NULL;
ALTER TABLE Users.[user] ADD CONSTRAINT PK_user_user_id PRIMARY KEY (user_id);
GO
