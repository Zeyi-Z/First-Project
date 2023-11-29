SELECT *
FROM dbo.Divvy_Trips_2019_Q2
Order by 10 DESC

SELECT Rental_Duration_seconds, Start_Station_Name, End_Station_Name, User_Type, Gender, Member_Birthday_Year, COALESCE(Gender, 'DNA') AS Gender
FROM dbo.Divvy_Trips_2019_Q2
Order by 1,4,5 ASC

--updating customers with no gender or birthyear
UPDATE dbo.Divvy_Trips_2019_Q2
SET Gender = COALESCE(Gender, 'DNA') 

-- replacing birthyear NULLS with N/A
SELECT Rental_Duration_seconds, Start_Station_Name, End_Station_Name, User_Type, Gender, Member_Birthday_Year, COALESCE(Member_Birthday_Year, '000') AS Member_Birthday_Year
FROM dbo.Divvy_Trips_2019_Q2
Order by 1,4,5 ASC

UPDATE dbo.Divvy_Trips_2019_Q2
SET Member_Birthday_Year = COALESCE(Member_Birthday_Year, '000')

--New table with no null values
SELECT Rental_Duration_seconds, Start_Station_Name, End_Station_Name, User_Type, Gender, Member_Birthday_Year
FROM dbo.Divvy_Trips_2019_Q2
Order by 1,4,5 ASC
--Finding out how many females and males(and DNA) are in the Q2 group
SELECT
    gender,
    COUNT(*) AS gender_count
FROM
    dbo.Divvy_Trips_2019_Q2
GROUP BY
    gender;
--Attempting to categorize age using the Birth_Year column
SELECT
    Member_Birthday_Year,
    CASE
        WHEN Member_Birthday_Year BETWEEN 1965 AND 1980 THEN 'Generation X'
        WHEN Member_Birthday_Year BETWEEN 1981 AND 1996 THEN 'Millennials'
        WHEN Member_Birthday_Year BETWEEN 1997 AND 2012 THEN 'Generation Z'
		WHEN Member_Birthday_Year BETWEEN 1946 AND 1964 THEN 'Baby Boomers'
		WHEN Member_Birthday_Year BETWEEN 1921 AND 1946 THEN 'Silent Generation'
        -- Add more conditions for other generations if needed
        ELSE 'Unknown Generation'
    END AS generation
FROM dbo.Divvy_Trips_2019_Q2
--Add generation column to the table
ALTER TABLE dbo.Divvy_Trips_2019_Q2
ADD generation VARCHAR(50);
UPDATE dbo.Divvy_Trips_2019_Q2
SET generation =
	CASE
		WHEN Member_Birthday_Year BETWEEN 1981 AND 1996 THEN 'Millennials'
        WHEN Member_Birthday_Year BETWEEN 1997 AND 2012 THEN 'Generation Z'
        WHEN Member_Birthday_Year BETWEEN 1965 AND 1980 THEN 'Generation X'
		WHEN Member_Birthday_Year BETWEEN 1946 AND 1964 THEN 'Baby Boomers'
		WHEN Member_Birthday_Year BETWEEN 1921 AND 1946 THEN 'Silent Generation'
        -- Add more conditions for other generations if needed
        ELSE 'Unknown Generation'
    END
--Still cleaning, filtering out the unkown genders and generations
SELECT Rental_Duration_seconds, Start_Station_Name, End_Station_Name, User_Type, Gender, generation 
FROM dbo.Divvy_Trips_2019_Q2
WHERE gender != 'DNA' AND Start_Station_Name <> End_Station_Name AND generation != 'Unknown Generation' 
Order by 4,5,1 DESC

--recounting Subscriber and Gender
SELECT
    gender,
    COUNT(*) AS gender_count
FROM
    dbo.Divvy_Trips_2019_Q2
WHERE gender != 'DNA'
GROUP BY
    gender;
--redoing the table
SELECT Rental_Duration_seconds, Start_Station_Name, End_Station_Name, User_Type, Gender, generation 
FROM dbo.Divvy_Trips_2019_Q2
WHERE gender != 'DNA' AND Start_Station_Name <> End_Station_Name AND generation != 'Unknown Generation' 
Order by 4,5,1 DESC

--user type count #1
SELECT
    (SELECT COUNT(*) FROM dbo.Divvy_Trips_2019_Q2 WHERE User_Type = 'customer' AND gender = 'male') AS Male_Customer,
    (SELECT COUNT(*) FROM dbo.Divvy_Trips_2019_Q2 WHERE User_Type = 'customer' AND gender = 'female') AS Female_Customer,
    (SELECT COUNT(*) FROM dbo.Divvy_Trips_2019_Q2 WHERE User_Type = 'subscriber' AND gender = 'male') AS Male_Subscriber,
    (SELECT COUNT(*) FROM dbo.Divvy_Trips_2019_Q2 WHERE User_Type = 'subscriber' AND gender = 'female') AS Female_Subscriber;
-- Counting customers and subscribers based on gender(#2)
SELECT
    generation,
    SUM(CASE WHEN User_Type = 'customer' AND gender = 'male' THEN 1 ELSE 0 END) AS MaleCustomer,
    SUM(CASE WHEN User_Type = 'customer' AND gender = 'female' THEN 1 ELSE 0 END) AS FemaleCustomer,
    SUM(CASE WHEN User_Type = 'subscriber' AND gender = 'male' THEN 1 ELSE 0 END) AS MaleSubscriber,
    SUM(CASE WHEN User_Type = 'subscriber' AND gender = 'female' THEN 1 ELSE 0 END) AS FemaleSubscriber
FROM dbo.Divvy_Trips_2019_Q2
WHERE generation != 'Unknown Generation'
GROUP BY generation;
--total time traveled based on generations
SELECT
    User_Type, SUM(Rental_Duration_Seconds)/3600 AS TotalHrTraveled
	FROM dbo.Divvy_Trips_2019_Q2 
	WHERE User_Type !='DNA' 
	GROUP BY User_Type
--Cleaned table for visualization
SELECT User_Type, Start_Station_Name, End_Station_Name, Round(Rental_Duration_Seconds/3600,2) AS TotalHrTraveled, Gender, generation 
FROM dbo.Divvy_Trips_2019_Q2
WHERE gender != 'DNA' AND Start_Station_Name <> End_Station_Name AND generation != 'Unknown Generation' 
Order by 1,5,6 DESC
