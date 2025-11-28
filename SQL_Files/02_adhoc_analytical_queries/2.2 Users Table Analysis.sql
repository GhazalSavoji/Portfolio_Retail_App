-- 2.2.1 Total users
SELECT COUNT(*) AS Total_users
FROM Users.[user];
GO

-- 2.2.2 Total countries
SELECT COUNT(DISTINCT location_country) AS Total_countries
FROM Users.[user]
WHERE location_country IS NOT NULL;
GO

-- 2.2.3 Unique countries
SELECT DISTINCT location_country 
FROM Users.[user]
WHERE location_country IS NOT NULL;
GO

-- 2.2.4 Total subscribed users
SELECT COUNT(*) AS Total_Subscribed_Users
FROM Users.[user]
WHERE is_subscribed = 1;
GO

-- 2.2.5 Countries with most subscribed users
SELECT location_country, COUNT(*) AS Subscribed 
FROM Users.[user]
WHERE is_subscribed = 1
GROUP BY location_country
ORDER BY Subscribed DESC;
GO

-- 2.2.6 Subscribed vs unsubscribed counts
SELECT is_subscribed, COUNT(*) AS NumberUsers
FROM Users.[user]
GROUP BY is_subscribed;
GO

-- 2.2.7 Under 19 users
SELECT 
COUNT(DISTINCT CASE WHEN user_age <19 THEN user_id END) AS Under_19_Users,
COUNT(DISTINCT CASE WHEN user_age <19 AND is_subscribed=1 THEN user_id END) AS Under_19_Users_Subscribed
FROM Users.[user];
GO

-- 2.2.8 Filter under 19 subscribed users
SELECT TOP 9 USER_ID, location_country, user_age, is_subscribed
FROM Users.[user]
WHERE user_age <19
ORDER BY user_age DESC;
GO

-- 2.2.9 Iranian users count
SELECT COUNT(*) AS Number_of_Iranians 
FROM Users.[user]
WHERE location_country IN ('IRAN', 'IR');
GO

-- 2.2.10 User demographics by country
SELECT 
	location_country,
	COUNT(user_id) AS N_users,
	AVG(user_age) AS AVG_age,
	MIN(user_age) AS Min_age,
	MAX(user_age) AS Max_age
FROM Users.[user]
WHERE user_age > 15  
GROUP BY location_country
HAVING COUNT(user_ID) > 300;
GO

-- 2.2.11 Phone numbers with 20 characters
SELECT * 
FROM Users.[user]
WHERE phone_number LIKE '_______________';
GO

-- 2.2.12 Countries starting with 'g'
SELECT * 
FROM Users.[user]
WHERE location_country LIKE 'g%';

-- 2.2.13 Age count with CTE
-- [Full query remains exactly as-is]
--****Pracitce subqueries, CTE, and windows function***
--2.2.13. Count users with different ages
WITH AgeCounts AS (
    SELECT
        COUNT(CASE WHEN user_age < 15 THEN user_id END) AS Child,
		COUNT(CASE WHEN user_age < 15 AND is_subscribed = 1 THEN user_id END) AS Child_Subscribed,
        COUNT(CASE WHEN user_age BETWEEN 15 AND 19 THEN user_id END) AS Teenage,
		COUNT(CASE WHEN user_age BETWEEN 15 AND 19 AND is_subscribed = 1 THEN user_id END) AS Teen_Subscribed,
        COUNT(CASE WHEN user_age BETWEEN 20 AND 39 THEN user_id END) AS Young,
		COUNT(CASE WHEN user_age BETWEEN 20 AND 39 AND is_subscribed = 1 THEN user_id END) AS Young_Subscribed,
        COUNT(CASE WHEN user_age BETWEEN 40 AND 59 THEN user_id END) AS Middle_age,
		COUNT(CASE WHEN user_age BETWEEN 40 AND 59 AND is_subscribed = 1 THEN user_id END) AS Middle_Subscribed,
        COUNT(CASE WHEN user_age >= 60 THEN user_id END) AS Elderly,
		COUNT(CASE WHEN user_age >= 60 AND is_subscribed = 1 THEN user_id END) AS Elderly_Subscribed,
        COUNT(CASE WHEN user_age IS NULL THEN user_id END) AS Unknown_Age,
        COUNT(*) AS Total,
		COUNT(CASE WHEN is_subscribed = 1 THEN user_id END) AS Total_Subscribed
    FROM Users.[user]
)
SELECT
    Child,
    Child * 100.0 / Total AS Child_Percent,
	Child_Subscribed,

    Teenage,
    Teenage * 100.0 / Total AS Teenage_Percent,
	Teen_Subscribed,

    Young,
    Young * 100.0 / Total AS Young_Percent,
	Young_Subscribed,

    Middle_age,
    Middle_age * 100.0 / Total AS Middle_age_Percent,
	Middle_Subscribed,

    Elderly,
    Elderly * 100.0 / Total AS Elderly_Percent,
	Elderly_Subscribed,

    Unknown_Age,
    Unknown_Age * 100.0 / Total AS Unknown_Percent,

	Total_Subscribed,
	Total
FROM AgeCounts;

--2.2.14. What is the percentage of users from each country?
-- Scalar subqueries
SELECT
	location_country,
	COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Users.[user]) AS Percent_User
	FROM Users.[user]
	GROUP BY location_country
	ORDER BY Percent_User DESC

-- Do the same with a windows function for better performance
SELECT
	location_country,
	(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER()) AS Percent_User
	FROM Users.[user]
	GROUP BY location_country
	ORDER BY Percent_User DESC
GO
-- 2.2.15. Countries with an average age higher than the total users' average age
-- Do with subquery
SELECT location_country, AVG (user_age) AS Country_Age 
FROM Users.[user] GROUP BY location_country 
HAVING AVG (user_age) > (SELECT AVG(user_age) FROM Users.[user])
ORDER BY AVG (user_age) DESC

-- Do the same with CTE and windows function
WITH GlobalAvgAge AS (
		SELECT 
			user_age,
			location_country,
			AVG (user_age) OVER() AS TotalAvgAge
		FROM Users.[user]
),
AvgAgeStat AS (
		SELECT 
			location_country,
			AVG(user_age) AS AvgCountryAge,
			MAX(TotalAvgAge) AS TotalAvgAge
		FROM GlobalAvgAge
		GROUP BY location_country
		)
SELECT location_country, AvgCountryAge
FROM AvgAgeStat	
WHERE AvgCountryAge > TotalAvgAge	
ORDER BY AvgCountryAge DESC;


--2.2.16. Show users whose ages are lower than their country's average age
--Corelated subquery
SELECT 
	user_id, u.location_country, u.user_age, u.is_subscribed
	FROM Users.[user] u
	WHERE user_age < (SELECT AVG(user_age) 
						FROM Users.[user] 
						WHERE location_country = u.location_country)
	ORDER BY u.user_age DESC

-- Do the same with CTE
SELECT 
    u.user_id,
    u.location_country,
    u.user_age,
    u.is_subscribed
FROM Users.[user] u
CROSS JOIN CountryAveAge c
WHERE u.location_country = c.location_country
  AND u.user_age < c.CountryAvgAge
ORDER BY u.user_age DESC;


--2.2.17. Countries where the number of their subscribed users is greater than 
--the average number of subscribed users across all countries.

SELECT location_country, COUNT(*) AS N_SUBS
	FROM Users.[user]
	WHERE is_subscribed = 1
	GROUP BY location_country
	HAVING COUNT(*) > (
		SELECT AVG(CountrySubsNum)
		FROM(
			SELECT COUNT(*) AS CountrySubsNum
			FROM Users.[user]
			WHERE is_subscribed = 1
			GROUP BY location_country
			) AS Country_Subs
	)
ORDER BY N_SUBS DESC
;
-- Do the same with CTE for better performance
WITH Country_Subs AS(
			SELECT 
				COUNT(*) AS CountrySubsNums,
				location_country
			FROM Users.[user]
			WHERE is_subscribed = 1
			GROUP BY location_country),
AvgCount AS (
			SELECT 
				AVG(CountrySubsNums) AS AVG_AMOUNT
			FROM Country_Subs
)
SELECT c.location_country, c.CountrySubsNums
FROM Country_Subs c
CROSS JOIN AvgCount a
WHERE  c.CountrySubsNums > a.AVG_AMOUNT
ORDER BY c.CountrySubsNums DESC;
GO
--- Do the same with one CTE and a windows function
WITH Country_Subs2 AS(
			SELECT 
				COUNT(*) AS CountrySubsNums,
				AVG(COUNT(*)) OVER() AS AVG_AMOUNT,
				location_country
			FROM Users.[user]
			WHERE is_subscribed = 1
			GROUP BY location_country
)
SELECT location_country, CountrySubsNums
FROM Country_Subs2
WHERE CountrySubsNums > AVG_AMOUNT
ORDER BY CountrySubsNums DESC;

--2.2.18. Users in countries where the average users' age is older than 30
--Multivarient subquery
SELECT *
FROM Users.[user]
WHERE location_country IN (
		SELECT location_country
		FROM Users.[user]
		GROUP BY location_country
		HAVING AVG(user_age) >30
		)
GO
-- List of countries that have at least one user in common.
SELECT DISTINCT location_country
FROM Users.[user]
WHERE user_id IN (
		SELECT user_id
		FROM Users.[user]
		WHERE is_subscribed = 1
		);
GO