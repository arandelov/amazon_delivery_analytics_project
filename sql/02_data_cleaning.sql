---------------------------------
-- Data Cleaning the ORDERS Table
---------------------------------


-- Inspect the orders table
SELECT * FROM orders LIMIT 20;

-- Get the total number of rows in the data
SELECT COUNT(*) AS Total_Num_Rows
FROM orders;

-- Get the number of rows with missing or null values, and the percentage of them
SELECT
    COUNT(*) AS Total_Missing_Rows,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders) * 100, 2) AS Percentage_Missing
FROM orders
WHERE 
    Order_ID IS NULL OR Order_ID = '' OR
    Store_Latitude IS NULL OR Store_Latitude = 0 OR
    Store_Longitude IS NULL OR Store_Longitude = 0 OR
    Drop_Latitude IS NULL OR Drop_Latitude = 0 OR
    Drop_Longitude IS NULL OR Drop_Longitude = 0 OR
    Order_Date IS NULL OR Order_Time IS NULL OR Pickup_Time IS NULL OR
    Area IS NULL OR Area = '' OR
    Category IS NULL OR Category = '' OR
    Delivery_Time IS NULL OR
    Weather IS NULL OR Weather = '' OR
    Traffic IS NULL OR Traffic = '' OR
    Vehicle IS NULL OR Vehicle = '';


-- Get the number of missing values per column
SELECT
    SUM(CASE WHEN Order_ID IS NULL OR Order_ID = '' THEN 1 ELSE 0 END) AS Order_ID_missing,
    SUM(CASE WHEN Store_Latitude IS NULL THEN 1 ELSE 0 END) AS Store_Latitude_missing,
    SUM(CASE WHEN Store_Longitude IS NULL THEN 1 ELSE 0 END) AS Store_Longitude_missing,
    SUM(CASE WHEN Drop_Latitude IS NULL THEN 1 ELSE 0 END) AS Drop_Latitude_missing,
    SUM(CASE WHEN Drop_Longitude IS NULL THEN 1 ELSE 0 END) AS Drop_Longitude_missing,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Order_Date_missing,
    SUM(CASE WHEN Order_Time IS NULL THEN 1 ELSE 0 END) AS Order_Time_missing,
    SUM(CASE WHEN Pickup_Time IS NULL THEN 1 ELSE 0 END) AS Pickup_Time_missing,
    SUM(CASE WHEN Area IS NULL OR Area = '' THEN 1 ELSE 0 END) AS Area_missing,
    SUM(CASE WHEN Category IS NULL OR Category = '' THEN 1 ELSE 0 END) AS Category_missing,
    SUM(CASE WHEN Delivery_Time IS NULL THEN 1 ELSE 0 END) AS Delivery_Time_missing,
    SUM(CASE WHEN Weather IS NULL OR Weather = '' THEN 1 ELSE 0 END) AS Weather_missing,
    SUM(CASE WHEN Traffic IS NULL OR Traffic = '' THEN 1 ELSE 0 END) AS Traffic_missing,
    SUM(CASE WHEN Vehicle IS NULL OR Vehicle = '' THEN 1 ELSE 0 END) AS Vehicle_missing
FROM orders;

-- Confirm that both Weather and Traffic are missing from the same rows
SELECT Order_ID, Weather, Traffic
FROM orders
WHERE Weather IS NULL OR Weather = ''
OR Traffic IS NULL OR Traffic = '';

-- Check invalid or suspicious coordinates for latitude and longitude
SELECT *
FROM orders
WHERE Store_Latitude NOT BETWEEN -90 AND 90
   OR Store_Longitude NOT BETWEEN -180 AND 180
   OR Drop_Latitude NOT BETWEEN -90 AND 90
   OR Drop_Longitude NOT BETWEEN -180 AND 180
   OR ABS(Store_Latitude) < 0.01
   OR ABS(Store_Longitude) < 0.01
   OR ABS(Drop_Latitude) < 0.01
   OR ABS(Drop_Longitude) < 0.01
LIMIT 20;

-- Check if there are negative values for latitude and longitude (mostly all are positive for pickup and dropoff)
SELECT 
    COUNT(*) AS Num_Negative_Coordinates,
    COUNT(*) / (SELECT COUNT(*) FROM orders) * 100 AS Percentage_Negative_Coordinates
FROM orders
WHERE Store_Latitude < 0 OR
      Store_Longitude < 0 OR
      Drop_Latitude < 0 OR
      Drop_Longitude < 0;   

-- Inspect rows with the negative coordinates
SELECT * 
FROM orders
WHERE Store_Latitude < 0 OR
      Store_Longitude < 0 OR
      Drop_Latitude < 0 OR
      Drop_Longitude < 0
LIMIT 20;   

-- Check if there are any data entries where all coordinates are negative
SELECT COUNT(*) AS Num_Rows_All_Negative_Coor
FROM orders
WHERE Store_Latitude < 0 AND
      Store_Longitude < 0 AND
      Drop_Latitude < 0 AND
      Drop_Longitude < 0;  


-- Check the total range of dates in the data
SELECT 
    MIN(Order_Date) AS earliest_order,
    MAX(Order_Date) AS latest_order,
    DATEDIFF(MAX(Order_Date), MIN(Order_Date)) AS total_days,
    DATEDIFF(MAX(Order_Date), MIN(Order_Date)) / 7 AS total_weeks,
    DATEDIFF(MAX(Order_Date), MIN(Order_Date)) / 30 AS total_months
FROM orders;

-- Check the range, minimum and maximum values for delivery times
SELECT 
    (MAX(Delivery_Time) - MIN(Delivery_Time)) AS Delivery_Time_Range,
    MAX(Delivery_Time) AS Max_Delivery_Time,
    MIN(Delivery_Time) AS Min_Delivery_Time
FROM orders;


-- Check for duplicates
SELECT MIN(Order_ID) AS Duplicated_ID, COUNT(*) AS Num_Of_Duplicates,
       Store_Latitude, Store_Longitude, Drop_Latitude, Drop_Longitude,
       Order_Date, Order_Time, Pickup_Time, Area, Category, Delivery_Time, Weather, Traffic, Vehicle
FROM orders
GROUP BY 
       Store_Latitude, Store_Longitude, Drop_Latitude, Drop_Longitude,
       Order_Date, Order_Time, Pickup_Time, Area, Category, Delivery_Time, Weather, Traffic, Vehicle
HAVING Num_Of_Duplicates > 1;



-- Check that the vehicles aren't capitalized
SELECT DISTINCT Vehicle
FROM orders;

-- Check the spelling mistake in one of the areas
SELECT DISTINCT Area
FROM orders;



-- Enable altering the table in MySql
SET SQL_SAFE_UPDATES = 0;

-- Correct the error of 'Metropolitian' to 'Metropolitan' for the area
UPDATE orders
SET Area = 'Metropolitan'
WHERE Area LIKE '%Metropolitian%';

-- Make the first letter of the vehicle capitalized, like in other columns
UPDATE orders
SET Vehicle = CONCAT(
    UPPER(LEFT(TRIM(Vehicle), 1)),        
    LOWER(SUBSTRING(TRIM(Vehicle), 2))  
);

-- Convert empty strings to NULL values (for Weather and Traffic columns) and
-- Convert store coordinates to NULL values where they have a value of 0
UPDATE orders
SET 
    Weather = NULLIF(Weather, ''),
    Traffic = NULLIF(Traffic, ''),
    Store_Latitude = NULLIF(Store_Latitude, 0),
    Store_Longitude = NULLIF(Store_Longitude, 0);
    
-- Convert drop coordinates to NULL where store coordinates are NULL
UPDATE orders
SET 
    Drop_Latitude = NULL,
    Drop_Longitude = NULL
WHERE Store_Latitude IS NULL OR Store_Longitude IS NULL;

-- Convert negative coordinate values into positive, and flag the changed columns
ALTER TABLE orders
ADD COLUMN Coordinates_Corrected_Flag VARCHAR(20);

UPDATE orders
SET
    Coordinates_Corrected_Flag = 'Modified',
    Store_Latitude = ABS(Store_Latitude),
    Store_Longitude = ABS(Store_Longitude),
    Drop_Latitude = ABS(Drop_Latitude),
    Drop_Longitude = ABS(Drop_Longitude)
WHERE
    Store_Latitude < 0 
    OR Store_Longitude < 0
    OR Drop_Latitude < 0
    OR Drop_Longitude < 0;

-- For underage agents, set that they can only (legally) use bicycle as means of transportation
UPDATE orders o
JOIN agents a ON o.Order_ID = a.Order_ID
SET o.Vehicle = NULL
WHERE a.Agent_Age < 18 
  AND o.Vehicle IN ('Van', 'Motorcycle', 'Scooter');

-- Disable altering the table in MySql
SET SQL_SAFE_UPDATES = 1;


--------------------------------
-- Data Cleaning the AGENTS Table
----------------------------------


-- Inspect the agents table
SELECT * FROM agents LIMIT 20;

-- Get the number of rows with missing values
SELECT COUNT(*) as num_missing, 
	ROUND(COUNT(*) / (SELECT COUNT(*) FROM agents) * 100,2) AS pct_missing
FROM agents
WHERE Agent_Age IS NULL OR Agent_Age = 0
OR Agent_Rating IS NULL OR Agent_Rating = 0;

-- Check which column has invalid or suspicious values (ratings go from 1 to 5)
SELECT * FROM agents
WHERE Agent_Age IS NULL OR Agent_Age = 0
OR Agent_Rating IS NULL OR Agent_Rating = 0
OR Agent_Rating > 5 OR Agent_Rating < 1;

-- Check the rating values and the number of agents with that rating
SELECT Agent_Rating, COUNT(*) as num_of_ratings
FROM agents
GROUP BY Agent_Rating
ORDER BY Agent_Rating DESC;

-- Check which agents have a rating of 1
SELECT * 
FROM agents
WHERE Agent_Rating = 1; 

-- Check the next agent older than 15
SELECT Agent_Age, Agent_Rating
FROM agents
WHERE Agent_Age <> 15
ORDER BY Agent_Age ASC
LIMIT 1;

-- Enable altering the table in MySql
SET SQL_SAFE_UPDATES = 0;

-- Convert invalid agent ratings to NULL values
UPDATE agents
SET 
    Agent_Rating = NULL
WHERE Agent_Rating <= 1 OR Agent_Rating>5;

-- Disable altering the table in MySql
SET SQL_SAFE_UPDATES = 1;

-- Get the number of rows with NULL values and the percentage
SELECT COUNT(*) as num_null_rows, 
	ROUND(COUNT(*) / (SELECT COUNT(*) FROM agents) * 100,2) AS pct_null
FROM agents
WHERE Agent_Rating IS NULL;