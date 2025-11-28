--=============================================
--SECTION 2-5: Analyzing 'session' table
--=============================================
-- 2.5.1 Check the table's structure and schema
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'session'
ORDER BY ORDINAL_POSITION
----Table schema
SELECT TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'session'
GO
--2.5.2 Average of session duration
SELECT 
	AVG(session_duration_sec) AS AvgDuration,
	AVG(battery_level) AS AvgBattery_level,
	AVG(memory_usage_mb) AS AvgMemory_usage_mb,
	COUNT(DISTINCT session_id) AS NumSessions
FROM EVENTS.[session]
GO

--2.5.3. Average of session duration by push-status
SELECT 
	push_enabled,
	AVG(session_duration_sec) AS AvgDuration,
	AVG(battery_level) AS AvgBattery_level,
	AVG(memory_usage_mb) AS Avgmemory_usage_mb,
	COUNT(*) AS NumSessions
FROM EVENTS.[session]
GROUP BY push_enabled
ORDER BY push_enabled

--2.5.4. Number of session per user
SELECT 
	user_id,
	COUNT(DISTINCT session_id) AS SessionCount
FROM EVENTS.[session]
GROUP BY user_id
ORDER BY SessionCount DESC; --*Result: Each user has one session in this table

--2.5.5 The highest number of network_types; with CTE
WITH NetworkStat AS (SELECT 
					COUNT(*) AS Total_networks
					FROM EVENTS.[session]
					)
SELECT 
	DISTINCT e.network_type,
	COUNT(*) AS CountNet,
	COUNT(*)*100.0/n.Total_networks AS PercentNet
FROM EVENTS.[session] e
CROSS JOIN NetworkStat n
GROUP BY e.network_type, n.Total_networks 
ORDER BY CountNet DESC;
GO
--The highest number of network_types; with windows function
SELECT 
    network_type,
    COUNT(*) AS CountNet,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS PercentNet
FROM EVENTS.[session]
GROUP BY network_type
ORDER BY CountNet DESC;