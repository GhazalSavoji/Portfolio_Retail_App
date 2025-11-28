--=============================================
--SECTION 2-3: Analyzing 'Device' table
--=============================================
-- 2.3.1 Check the table structure and schema
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'device'
ORDER BY ORDINAL_POSITION

--Table schema
SELECT TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'device'
GO
-- 2.3.2 Count different types of devices and screen and lang
SELECT 
	COUNT(DISTINCT device_os) AS DeviceTypes,
	COUNT(DISTINCT device_os_version) AS DeviceVersionTypes,
	COUNT(DISTINCT device_model) AS DeviceModelTypes,
	COUNT(DISTINCT screen_resolution) AS ScreenResolutionTypes,
	COUNT(DISTINCT app_language) AS app_languageTypes,
	COUNT(DISTINCT app_version) AS app_versionTypes
FROM Users.[device]
GO
---- 2.3.3 Number of users per language using 'subquery'
SELECT 
	app_language,	
	COUNT(*) AS Num_language,
	COUNT(*)*100.0/(SELECT COUNT(*) FROM Users.[device]) AS Percent_language
FROM Users.[device]
GROUP BY app_language
ORDER BY Num_language DESC
GO

--Do the same with 'CTE' for better performance
WITH DeviceStat AS (SELECT COUNT(*) AS TotalUsers FROM Users.[device])
SELECT 
	u.app_language,	
	COUNT(*) AS Num_language,
	COUNT(*)*100.0/d.TotalUsers AS Percent_language
FROM Users.[device] u
CROSS JOIN DeviceStat d
GROUP BY u.app_language, d.TotalUsers 
ORDER BY Num_language DESC
GO
--Do the same with 'windows function' for better performance
WITH LangStats AS (
    SELECT 
        app_language,
        COUNT(*) AS Num_Languages
    FROM Users.[device]
    GROUP BY app_language
)
SELECT 
    app_language,
    Num_Languages,
    Num_Languages * 100.0 / SUM(Num_Languages) OVER() AS Percent_Lang
FROM LangStats
ORDER BY Num_Languages DESC;

-- 2.3.4. Number of devices of each user
SELECT user_id, COUNT(DISTINCT device_id) AS N_devices
FROM Users.[device]
GROUP BY user_id
ORDER BY N_devices DESC;
GO
--2.3.5. Number of users using each version
SELECT app_version, COUNT(DISTINCT user_id) AS N_users
FROM Users.[device]
GROUP BY app_version
ORDER BY N_users DESC;

--2.3.6. Valid versions count
--It's very uncleand!
-- Then Number of devices using versions lower than 4

WITH Valid_Version AS (
	SELECT app_version,
		PARSENAME(app_version, 3) AS Major,
		PARSENAME(app_version, 2) AS Minor,
		PARSENAME(app_version, 1) AS Patch
	FROM Users.[device]
	WHERE app_version LIKE '[0-9]%.[0-9]%.[0-9]%'
	AND PARSENAME(app_version, 3) IS NOT NULL
	)
SELECT app_version, COUNT(*) AS device_count
FROM Valid_Version
GROUP BY app_version, Major, Minor,Patch
ORDER BY
	TRY_CONVERT(INT,Major) DESC, 
	TRY_CONVERT(INT,Minor) DESC,
	TRY_CONVERT(INT,Patch) DESC;

-- Number of devices using versions lower than 4.
WITH Valid_Version AS (
	SELECT app_version, device_id,
		PARSENAME(app_version, 3) AS Major,
		PARSENAME(app_version, 2) AS Minor,
		PARSENAME(app_version, 1) AS Patch
	FROM Users.[device]
	WHERE app_version LIKE '[0-9]%.[0-9]%.[0-9]%'
	AND PARSENAME(app_version, 3) IS NOT NULL
	)
SELECT COUNT(device_id) AS device_count
FROM Valid_Version
WHERE Major < 4
