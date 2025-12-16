----------------------------
-- Feature Engineering
----------------------------

-- Make a VIEW and join the orders and agents table together
CREATE OR REPLACE VIEW orders_agents_joined AS
SELECT o.*, a.Agent_Age, a.Agent_Rating
FROM orders o
INNER JOIN agents a
    ON o.Order_ID = a.Order_ID;


-- Contruct a new VIEW with feature engineered columns
CREATE OR REPLACE VIEW orders_agents_analytics AS
SELECT
    Order_ID,
    Store_Latitude,
    Store_Longitude,
    Drop_Latitude,
    Drop_Longitude,
    Order_Date,
    Order_Time,
    Pickup_Time,
    Area,
    Category,
    Delivery_Time,
    Weather,
    Traffic,
    Vehicle,
    Agent_Age,
    Agent_Rating,
    -- Add a new column with dropoff date and time
    TIMESTAMPADD(MINUTE, Delivery_Time, CONCAT(Order_Date, ' ', Pickup_Time)) AS Dropoff_Datetime,
    -- Add a new column to calculate the distance between store and dropoff location (Haversine formula)
    ROUND(6371 * ACOS(
        COS(RADIANS(Store_Latitude)) 
      * COS(RADIANS(Drop_Latitude)) 
      * COS(RADIANS(Drop_Longitude) - RADIANS(Store_Longitude)) 
      + SIN(RADIANS(Store_Latitude)) 
      * SIN(RADIANS(Drop_Latitude))
    ),2) AS Distance_KM,
    -- Create a pickup date column, to flag the orders picked up the next day
    CASE
        WHEN TIMESTAMP(CONCAT(Order_Date, ' ', Pickup_Time)) 
                < TIMESTAMP(CONCAT(Order_Date, ' ', Order_Time)) THEN 
                DATE_ADD(Order_Date, INTERVAL 1 DAY)
                ELSE Order_Date
    END AS Pickup_Date,

    -- Categorize the pickup times into periods of the day
    CASE 
        WHEN Pickup_Time BETWEEN '00:00:00' AND '06:59:59' THEN 'Night (midnight to 1am)'
        WHEN Pickup_Time BETWEEN '07:00:00' AND '11:59:59' THEN 'Morning'
        WHEN Pickup_Time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        WHEN Pickup_Time BETWEEN '17:00:00' AND '23:59:59' THEN 'Evening'
    END AS Pickup_Time_Period,
    -- Categorize orders made on weekday vs. weekend
    CASE 
        WHEN DAYOFWEEK(Order_Date) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type_Order
FROM orders_agents_joined;

-- Contruct a VIEW to examiine delivery times and dates
CREATE OR REPLACE VIEW delivery_analysis AS
SELECT
    Order_ID,
    Distance_KM,
    Order_Date,
    Order_Time,
    Pickup_Date,
    Pickup_Time,
    Dropoff_Datetime,
    Delivery_Time,
    Pickup_Time_Period,
    Day_Type_Order,
    Area,
    Category,
    Weather,
    Traffic
FROM orders_agents_analytics;


-- Construct a VIEW to analyze agent performance
CREATE OR REPLACE VIEW agents_performance_analysis AS
SELECT
    Order_ID,
    Distance_KM,
    Delivery_Time,
    ROUND((Distance_KM / (Delivery_Time / 60)),2) AS Speed_KMHR,
    Agent_Age,
    Agent_Rating,
    Vehicle,
    Area,
    -- Group the agent age and rating into bins
    CASE
        WHEN Agent_Age = 15 THEN '15'
        WHEN Agent_Age BETWEEN 20 AND 25 THEN '20–25'
        WHEN Agent_Age BETWEEN 26 AND 30 THEN '26–30'
        WHEN Agent_Age BETWEEN 31 AND 35 THEN '31–35'
        WHEN Agent_Age BETWEEN 36 AND 39 THEN '36–39'
        WHEN Agent_Age = 50 THEN '50'
    END AS Agent_Age_Bin,
    CASE
		WHEN Agent_Rating IS NULL THEN 'Not Rated'
		WHEN Agent_Rating BETWEEN 2.5 AND 2.9 THEN '2.5–2.9'
		WHEN Agent_Rating BETWEEN 3.0 AND 3.4 THEN '3.0–3.4'
		WHEN Agent_Rating BETWEEN 3.5 AND 3.9 THEN '3.5–3.9'
		WHEN Agent_Rating BETWEEN 4.0 AND 4.4 THEN '4.0–4.4'
		WHEN Agent_Rating BETWEEN 4.5 AND 4.7 THEN '4.5–4.7'
		WHEN Agent_Rating BETWEEN 4.8 AND 5.0 THEN '4.8–5.0'
    END AS Agent_Rating_Bin
FROM orders_agents_analytics;

-- Construct a VIEW for geographical analysis
CREATE OR REPLACE VIEW geographical_analysis AS
SELECT
    Order_ID,
    Store_Latitude,
    Store_Longitude,
    Drop_Latitude,
    Drop_Longitude,
    HOUR(Pickup_Time) AS Pickup_Hour,
    HOUR(Dropoff_Datetime) AS Dropoff_Hour,
    Area,
    Traffic
FROM orders_agents_analytics;



