--------------------------------
-- Delivery Analysis (general)
---------------------------------


-- Summarize orders and delivery statistics per area
SELECT 
    Area,
    COUNT(*) AS Orders_Per_Area,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders) * 100, 2) AS Percentage_Per_Area,
    ROUND(AVG(Delivery_Time),2) AS Avg_Delivery_Time,
    MIN(Delivery_Time) AS Min_Delivery_Time,
    MAX(Delivery_Time) AS Max_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Sd_Delivery_Time
FROM orders
GROUP BY Area
ORDER BY Orders_Per_Area DESC;

-- Summarize orders and delivery statistics per category
SELECT 
    Category,
    COUNT(*) AS Orders_Per_Category,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders) * 100, 2) AS Percentage_Per_Category,
    ROUND(AVG(Delivery_Time),2) AS Avg_Delivery_Time,
    MIN(Delivery_Time) AS Min_Delivery_Time,
    MAX(Delivery_Time) AS Max_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Sd_Delivery_Time
FROM orders
GROUP BY Category
ORDER BY Orders_Per_Category DESC;


-- Summarize orders and delivery statistics per weather
SELECT 
    Weather,
    COUNT(*) AS Orders_Per_Weather,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders) * 100, 2) AS Percentage_Per_Weather,
    ROUND(AVG(Delivery_Time),2) AS Avg_Delivery_Time,
    MIN(Delivery_Time) AS Min_Delivery_Time,
    MAX(Delivery_Time) AS Max_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Sd_Delivery_Time
FROM orders
GROUP BY Weather
ORDER BY Orders_Per_Weather DESC;

-- Summarize orders and delivery statistics per traffic
SELECT 
    Traffic,
    COUNT(*) AS Orders_Per_Traffic,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders) * 100, 2) AS Percentage_Per_Traffic,
    ROUND(AVG(Delivery_Time),2) AS Avg_Delivery_Time,
    MIN(Delivery_Time) AS Min_Delivery_Time,
    MAX(Delivery_Time) AS Max_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Sd_Delivery_Time
FROM orders
GROUP BY Traffic
ORDER BY Orders_Per_Traffic DESC;

-- Summarize orders and delivery statistics by area and category (combined)
SELECT 
    Area, 
    Category, 
    COUNT(*) AS Orders_Per_Area_Category,
    ROUND(AVG(Delivery_Time),2) AS Avg_Delivery_Time,
    MIN(Delivery_Time) AS Min_Delivery_Time,
    MAX(Delivery_Time) AS Max_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Sd_Delivery_Time
FROM orders
GROUP BY Area, Category
ORDER BY Orders_Per_Area_Category DESC;

-- Summarize orders and delivery statistics by area and traffic (combined)
SELECT
    Area,
    Traffic,
    COUNT(*) AS Orders_Per_Area_Traffic,
    ROUND(AVG(Delivery_Time), 2) AS Avg_Delivery_Time,
    MIN(Delivery_Time) AS Min_Delivery_Time,
    MAX(Delivery_Time) AS Max_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Sd_Delivery_Time
FROM orders
GROUP BY Area, Traffic
ORDER BY Area, Avg_Delivery_Time DESC;


-- Summarize orders and delivery statistics by category and weather (combined)
SELECT 
    Category,
    Weather,
    COUNT(*) AS Orders_Count,
    ROUND(AVG(Delivery_Time),2) AS Avg_Delivery_Time
FROM orders
GROUP BY Category, Weather
ORDER BY Orders_Count DESC;

-- Examine time gaps between order dates for different areas
SELECT *
FROM (
    SELECT
        Area,
        Order_Date,
        LAG(Order_Date) OVER (PARTITION BY Area ORDER BY Order_Date) AS Previous_Order_Date,
        DATEDIFF(Order_Date, LAG(Order_Date) OVER (PARTITION BY Area ORDER BY Order_Date)) AS Days_Since_Previous_Order
    FROM orders
) AS Daily_Orders_Gaps
WHERE Days_Since_Previous_Order > 1
ORDER BY Area, Order_Date;

-- Examine at what times the orders were made, and how many orders
SELECT 
    HOUR(Order_Time) AS Hour,
    COUNT(*) AS Num_Orders
FROM orders
GROUP BY HOUR(Order_Time)
ORDER BY Hour;

-- Examine the number of orders by period of a day
SELECT 
    CASE 
        WHEN HOUR(Order_Time) BETWEEN 0 AND 1 THEN 'Night (midnight to 1am)'
        WHEN HOUR(Order_Time) BETWEEN 7 AND 11 THEN 'Morning'
        WHEN HOUR(Order_Time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(Order_Time) BETWEEN 17 AND 23 THEN 'Evening'
    END AS Order_Time_Period,
    COUNT(*) AS Num_Orders,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders)*100,2) AS Percentage_Orders
FROM orders
GROUP BY Order_Time_Period;

-- Examine the number and percentage of orders on weekday vs. weekend
SELECT  
    Day_Type_Order,
    COUNT(*) AS Num_Orders,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders) * 100, 2) AS Percentage_Orders
FROM delivery_analysis
GROUP BY Day_Type_Order;

-- Examine the number of orders that were picked up during certain periods of a day
SELECT 
    Pickup_Time_Period,
    COUNT(*) AS Num_Orders,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM  orders)*100,2) AS Percentage_Orders
FROM delivery_analysis
GROUP BY Pickup_Time_Period;

-- Examine unusual times between order and pickup times (> 60 minutes)
SELECT 
    HOUR(Order_Time) AS Hour_Order,
    HOUR(Pickup_Time) AS Hour_Pickup,
    COUNT(*) AS Num_Orders
FROM orders
WHERE TIMESTAMPDIFF(MINUTE, Order_Time, Pickup_Time) > 60
GROUP BY HOUR(Order_Time), HOUR(Pickup_Time)
ORDER BY Hour_Order, Hour_Pickup;

-- Get the numbers and percentages of same-day and next-day deliveries
SELECT 
	COUNT(*) AS Num_Next_Day,
    (SELECT COUNT(*) FROM delivery_analysis) - COUNT(*) AS Num_Same_Day,
	ROUND(COUNT(*)/(SELECT COUNT(*) FROM delivery_analysis)*100,2) AS Pct_Delivered_Next_Day,
	ROUND((1 - COUNT(*)/(SELECT COUNT(*) FROM delivery_analysis))*100,2) AS Pct_Delivered_Same_Day
FROM delivery_analysis
WHERE Hour(Dropoff_Datetime) BETWEEN 1 and 4 
AND HOUR(Pickup_Time) <> 0;

-- Examine other order and pickup times (pickup taking less than 60 minutes)
SELECT 
    HOUR(Order_Time) AS Hour_Order,
    HOUR(Pickup_Time) AS Hour_Pickup,
    COUNT(*) AS Num_Orders
FROM orders
WHERE HOUR(Order_Time) > 0
GROUP BY HOUR(Order_Time), HOUR(Pickup_Time)
ORDER BY Hour_Order, Hour_Pickup;

-- Examine the dropoff times for the orders
SELECT 
    HOUR(Dropoff_Datetime) AS Dropoff_Hour, 
    COUNT(*) as Num_Orders
FROM delivery_analysis
GROUP BY Dropoff_Hour
ORDER BY Dropoff_Hour ASC;

-- Get the latest dropoff time (after midnight, and before morning)
SELECT 
    MAX(TIME(Dropoff_Datetime)) AS Latest_Dropoff_Time
FROM delivery_analysis
WHERE HOUR(Dropoff_Datetime) = 3;

-- Check which categories are ordered the most after midnight, and their delivery times
SELECT 
    Category, 
    AVG(Delivery_Time) AS Avg_Delivery_Time
FROM delivery_analysis
WHERE HOUR(Dropoff_Datetime) BETWEEN 0 AND 3
GROUP BY Category
ORDER BY AVG(Delivery_Time) DESC;

-- Group the dropoff times into time periods, and get the number and percentage of orders by period
SELECT 
	Dropoff_Period, 
	COUNT(*) AS Num_Orders,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM delivery_analysis) * 100, 2) AS Pct_Orders
FROM (
    SELECT 
        CASE
            WHEN HOUR(Dropoff_Datetime) BETWEEN 0 AND 3 THEN 'Night (midnight to 4am)'
            WHEN HOUR(Dropoff_Datetime) BETWEEN 8 AND 11 THEN 'Morning'
            WHEN HOUR(Dropoff_Datetime) BETWEEN 12 AND 16 THEN 'Afternoon'
            WHEN HOUR(Dropoff_Datetime) BETWEEN 17 AND 23 THEN 'Evening'
        END AS Dropoff_Period
    FROM delivery_analysis
) AS Dropoff_Sub
GROUP BY Dropoff_Period
ORDER BY Num_Orders Desc;


-- The maximum and minimum delivery distance in the dataset
SELECT 
	MIN(Distance_KM) AS Min_Distance,
	MAX(Distance_KM) AS Max_Distance
FROM delivery_analysis;
	
-- Examine the orders with minimal distance
SELECT *
FROM delivery_analysis
WHERE Distance_KM = (
    SELECT MIN(Distance_KM) 
    FROM delivery_analysis
);

-- Examine the orders with maximum distance
SELECT *
FROM delivery_analysis
WHERE Distance_KM = (
    SELECT MAX(Distance_KM) 
    FROM delivery_analysis
);

    
-- Group the distances into bins to investigate delivery times by distance and area
WITH DistanceBins AS (
    SELECT 
        Delivery_Time,
        Area,
        CASE
            WHEN Distance_KM >= 0 AND Distance_KM < 3 THEN '0-3'
            WHEN Distance_KM >= 3 AND Distance_KM < 7 THEN '3-7'
            WHEN Distance_KM >= 7 AND Distance_KM < 12 THEN '7-12'
            WHEN Distance_KM >= 12 AND Distance_KM < 17 THEN '12-17'
            ELSE '17-21'
        END AS Distance_Bin
    FROM delivery_analysis
)
SELECT
    Area,
    Distance_Bin,
    ROUND(AVG(Delivery_Time),2) AS Avg_Delivery_Time
FROM DistanceBins
GROUP BY Area, Distance_Bin
ORDER BY Distance_Bin, Area;



-- Check the relationship between distances and delivery times
SELECT 
    Distance_KM,
    COUNT(*) AS Num_Orders,
    ROUND(AVG(Delivery_Time),2) AS Avg_Delivery_Time,
    ROUND(STDDEV(Delivery_Time),2) AS Std_Dev
FROM delivery_analysis
WHERE Distance_KM IS NOT NULL
GROUP BY Distance_KM
ORDER BY Distance_KM;

-- Examine the relationship between distances and delivery times
SELECT 
    FLOOR(Distance_KM) AS Distance_KM_Floor,  
    COUNT(*) AS Num_Orders,
    ROUND(AVG(Delivery_Time), 2) AS Avg_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Std_Dev_Delivery_Time
FROM delivery_analysis
WHERE Distance_KM IS NOT NULL
GROUP BY Distance_KM_Floor
ORDER BY Distance_KM_Floor;

----------------------------------
-- Agent Performance Analysis
----------------------------------


-- Examine how many agents do not have a rating
SELECT 
    COUNT(*) AS Num_Missing_Ratings, 
    COUNT(*)/(SELECT COUNT(*) FROM agents)*100 AS Pct_Missing_Ratings
FROM agents
WHERE Agent_Rating IS NULL;

-- Check the average age and the range for agents, and also average rating and its range
SELECT 
    ROUND(AVG(Agent_Age), 2) AS Avg_Age,
    MIN(Agent_Age) AS Min_Age_No_Rating,
    (SELECT MIN(Agent_Age) FROM agents
    WHERE Agent_Age>15) AS Min_Age_Exist_Rating,
    MAX(Agent_Age) AS Max_Age,
    ROUND(AVG(Agent_Rating), 2) AS Avg_Rating,
    MIN(Agent_Rating) AS Min_Rating,
    MAX(Agent_Rating) AS Max_Rating
FROM agents;

-- Get the average delivery time and number of orders for each agent age bin
SELECT 
    Agent_Age_Bin,
    ROUND(AVG(Delivery_Time), 2) AS Avg_Delivery_Time,
    COUNT(*) AS Num_Orders
FROM agents_performance_analysis
GROUP BY Agent_Age_Bin
ORDER BY 
    CASE 
        WHEN Agent_Age_Bin = '15' THEN 1
        WHEN Agent_Age_Bin = '20–25' THEN 2
        WHEN Agent_Age_Bin = '26–30' THEN 3
        WHEN Agent_Age_Bin = '31–35' THEN 4
        WHEN Agent_Age_Bin = '36–39' THEN 5
        WHEN Agent_Age_Bin = '50' THEN 6
    END;

-- Get the average delivery time for each agent rating bin
SELECT 
    Agent_Rating_Bin,
    ROUND(AVG(Delivery_Time), 2) AS Avg_Delivery_Time,
    COUNT(*) AS Num_Orders
FROM agents_performance_analysis
GROUP BY Agent_Rating_Bin
ORDER BY 
    CASE 
        WHEN Agent_Rating_Bin = '2.5–2.9' THEN 1
        WHEN Agent_Rating_Bin = '3.0–3.4' THEN 2
        WHEN Agent_Rating_Bin = '3.5–3.9' THEN 3
        WHEN Agent_Rating_Bin = '4.0–4.4' THEN 4
        WHEN Agent_Rating_Bin = '4.5–4.7' THEN 5
        WHEN Agent_Rating_Bin = '4.8–5.0' THEN 6
    END;


-- Examine how many orders are delivered by agents of each rating, and average delivery times by rating
SELECT 
    Agent_Rating,
    COUNT(*) AS Num_Deliveries,
    AVG(Delivery_Time) AS Avg_Delivery_Time
FROM agents_performance_analysis
WHERE Agent_Rating IS NOT NULL
GROUP BY Agent_Rating
ORDER BY Agent_Rating DESC;

-- Inspect the agents with rating less than 4
SELECT 
    Agent_Age,
    Agent_Rating,
    COUNT(*) AS Num_Orders,
    AVG(Delivery_Time) AS Avg_Delivery_Time
FROM agents_performance_analysis
WHERE Agent_Rating < 4
GROUP BY Agent_Age, Agent_Rating
ORDER BY Agent_Rating DESC;


-- Inspect which agents are riding bicycles
SELECT Vehicle, Agent_Rating, Agent_Age
FROM orders_agents_analytics
WHERE Vehicle = 'Bicycle';

-- Examine the ratings and the vehicles of agents aged 50
SELECT Vehicle, Agent_Rating, Agent_Age
FROM orders_agents_analytics
WHERE Agent_Age = 50;


-- Examine if agents rating correlates with the distance they travelled
SELECT 
    FLOOR(Distance_KM) AS Distance_KM_Floored,
    ROUND(AVG(Agent_Rating), 2) AS Avg_Rating
FROM agents_performance_analysis
WHERE FLOOR(Distance_KM) IS NOT NULL
GROUP BY Distance_KM_Floored
ORDER BY Distance_KM_Floored;


-- Examine long-distance deliveries (>10 km) by traffic and weather
SELECT
    Traffic,
    Weather,
    COUNT(*) AS Num_Orders,
    ROUND(AVG(Delivery_Time), 2) AS Avg_Delivery_Time,
    ROUND(MIN(Delivery_Time), 2) AS Min_Delivery_Time,
    ROUND(MAX(Delivery_Time), 2) AS Max_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Std_Dev_Delivery_Time
FROM delivery_analysis
WHERE Distance_KM > 10 AND Weather IS NOT NULL
GROUP BY Traffic, Weather
ORDER BY Avg_Delivery_Time DESC, Num_Orders DESC;


-- Group the delivery time into bins of 1hr to examine the duration of delivery
SELECT 
    CASE 
        WHEN Delivery_Time < 60 THEN '<1 hour'
        WHEN Delivery_Time BETWEEN 60 AND 119 THEN '1-2 hours'
        WHEN Delivery_Time BETWEEN 120 AND 179 THEN '2-3 hours'
        WHEN Delivery_Time BETWEEN 180 AND 239 THEN '3-4 hours'
        ELSE '4+ hours'
    END AS Delivery_Time_Duration,
    COUNT(*) AS Num_Orders
FROM delivery_analysis
GROUP BY 
    Delivery_Time_Duration
ORDER BY Delivery_Time_Duration;


-- Examine the relationships between the pickup period, traffic and weather during delivery
SELECT
    Pickup_Time_Period,
    Traffic,
    Weather,
    COUNT(*) AS Num_Orders,
    ROUND(AVG(Delivery_Time), 2) AS Avg_Delivery_Time,
    ROUND(MIN(Delivery_Time), 2) AS Min_Delivery_Time,
    ROUND(MAX(Delivery_Time), 2) AS Max_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Sd_Delivery_Time
FROM delivery_analysis
WHERE Traffic IS NOT NULL
GROUP BY Pickup_Time_Period, Traffic, Weather
ORDER BY Avg_Delivery_Time DESC, Num_Orders DESC;


-- Examine the relationships between the pickup period, traffic and weather during delivery
SELECT
    Pickup_Time_Period,
    Traffic,
    Weather,
    COUNT(*) AS Num_Orders,
    ROUND(AVG(Delivery_Time), 2) AS Avg_Delivery_Time,
    ROUND(MIN(Delivery_Time), 2) AS Min_Delivery_Time,
    ROUND(MAX(Delivery_Time), 2) AS Max_Delivery_Time,
    ROUND(STDDEV(Delivery_Time), 2) AS Sd_Delivery_Time
FROM delivery_analysis
WHERE Traffic IS NOT NULL
GROUP BY Pickup_Time_Period, Traffic, Weather
ORDER BY Avg_Delivery_Time DESC, Num_Orders DESC;


----------------------------------------------
-- Delivery Analysis by Geospatial Location
----------------------------------------------



-- Get the number of missing and available location coordinates in the data
SELECT COUNT(*) AS Num_Missing_Coordinates,
	(SELECT COUNT(*) FROM geographical_analysis)-COUNT(*) AS Num_Available_Coordinates
FROM geographical_analysis
WHERE Store_Latitude IS NULL
    OR Store_Longitude IS NULL;


-- Examine distinct store locations and number of orders per location
SELECT  
    Store_Latitude, 
    Store_Longitude, 
    COUNT(*) AS Num_Orders
FROM geographical_analysis
WHERE Store_Latitude IS NOT NULL
GROUP BY Store_Latitude, Store_Longitude
ORDER BY Num_Orders DESC;

-- Examine distinct dropoff locations and number of orders per location
SELECT  
    Drop_Latitude, 
    Drop_Longitude, 
    COUNT(*) AS Num_Orders
FROM geographical_analysis
WHERE Drop_Latitude IS NOT NULL
GROUP BY Drop_Latitude, Drop_Longitude
ORDER BY Num_Orders DESC;

-- Get the total number of stores locations
SELECT COUNT(*) AS Num_Store_Locations
FROM (
    SELECT Store_Latitude, Store_Longitude
    FROM geographical_analysis
    GROUP BY Store_Latitude, Store_Longitude
) AS Distinct_Stores;

-- Get the total number of dropoff locations
SELECT COUNT(*) AS Num_Dropoff_Locations
FROM (
    SELECT Drop_Latitude, Drop_Longitude
    FROM geographical_analysis
    GROUP BY Drop_Latitude, Drop_Longitude
) AS Distinct_Dropoffs;

-- The number of distinct dropoff sites in each area (one dropoff site can appear in multiple areas )
SELECT Area, COUNT(*) AS Num_Distinct_Dropoffs
FROM (
    SELECT DISTINCT Area, Drop_Latitude, Drop_Longitude
    FROM geographical_analysis
    WHERE Drop_Latitude IS NOT NULL
      AND Drop_Longitude IS NOT NULL
) AS Distinct_Dropoffs
GROUP BY Area
ORDER BY Num_Distinct_Dropoffs DESC;