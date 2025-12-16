# Amazon Delivery Analytics Project 

This project analyzed Amazon delivery operations data in India, to obtain insights related to delivery performance, agent efficiency, and geospatial patterns. The data transformation and querying was done in **MySQL**, while the interactive dashboards and data visualizations were created using **PowerBI**.

The database `portfolioproject` contains two tables: **orders** and **agents** (defined in `01_database_setup.sql` file). Raw data is stored in the `data` folder, SQL scripts are in `sql`, and dashboards are in `dashboards`.

## Executive Summary

This analysis of 43,739 Amazon delivery orders in India (Feb–Apr 2022) reveals key patterns in delivery performance, agent efficiency, and geospatial coverage. Most orders occur in Metropolitan areas, with delivery times averaging 2 hours, while Semi-Urban zones experience the longest delays. Peak demand occurs in the evening (5–11 PM), and traffic jams significantly slow deliveries. Highly rated agents (4.5–5.0) are notably faster and more reliable, particularly for long-distance deliveries. Operational improvements should focus on peak-hour coverage, late-night order handling, leveraging top-rated agents, optimizing Semi-Urban delivery routes, and accounting for traffic in real-time routing. Implementing these strategies can reduce delivery times, improve efficiency, and enhance customer satisfaction.

## Dataset Description:

The orders table contains information about individual delivery orders, such as:
- **Order_ID**: Unique identifier for each order
- **Store_Latitude, Store_Longitude**: Geographic coordinates of the store where the order was placed
- **Drop_Latitude, Drop_Longitude**: Geographic coordinates of the delivery location
- **Order_Date, Order_Time**: Date and time when the order was placed
- **Pickup_Time**: Time when the order was picked up for delivery
- **Weather**: Weather conditions during the delivery (e.g., sunny, rainy, snowy)
- **Traffic**: Traffic conditions during the delivery (e.g., low, medium, jam)
- **Vehicle**: Type of vehicle used for the delivery (e.g., van, motorcycle, bicycle, scooter)
- **Area**: Area where the delivery took place (Urban, Metropolitan,etc)
- **Delivery_Time**: Time taken to complete the delivery (in minutes)
- **Category**: Product category of the ordered item (e.g., electronics, apparel, groceries)

The agents table contains information about order ID's and agents who performed the deliveries:
- **Order_ID**: Unique identifier for each order
- **Agent_Age**: Age of the delivery agent
- **Agent_Rating**: Rating or performance score of the delivery agent (1-5)

There are 43,739 rows spanning dates from 11 Feb 2022 to 6 Apr 2022.

## Data Cleaning

**Orders table**: Checked for missing values, duplicates, invalid/negative coordinates, and inconsistent text entries. Corrected text capitalization (Vehicle column), typos (Area column) and negative coordinates or invalid values. All of the missing or invalid values were set to NULL, to ensure consistency across the whole dataset as well as easier querying. About 8.2% of rows had at least one missing value, with them being predominantly coordinates. Joined agents and orders tables to change the only allowed vehicle for underage agents to bicycle. 

**Agents table**: About 0.33% of rows contained missing values, with all of them being in the Agent Rating column. Ratings less or equal to null, and larger than 5 were set to NULL.  

## Feature Engineering

Several views are created to avoid modifying the tables directly:
1. **orders_agents_joined** - joined orders and agents tables
2. **orders_agents_analytics** - added derived columns to orders_agents_joined, such as
- Dropoff_Datetime: timestamp for the delivery time and date
- Distance_KM: distance (in km) between store and delivery location (using Haversine formula)
- Pickup_Date: flags orders picked up the next day
- Pickup_Time_Period: grouped values into daily period bins (Night, Morning, Afternoon, Evening)
- Day_Type_Order – flags weekday vs weekend orders
3. **delivery_analysis** - focused on delivery dates, times, and other conditions (weather, area, traffic)
4. **agents_performance_analysis**: focused on agents and their performance, delivery times, with added bins for agent rating and age
5. **geographical_analysis**: prepared the data for geographical analysis, with calculating pickup/dropoff hours to observe patterns, and included traffic and area info

## Exploratory Data Analysis


### Delivery Analysis Insights

* Most orders occur in Metropolitan areas (~75%), with average delivery times around 130 min. Urban areas are slightly faster (~109 min), while Semi-Urban zones experience the longest delays (~239 min) despite lower volume.
* Delivery times range from 10 to 270 min, and they increase with delivery distance with moderate variability (~45–52 min), especially in Semi-Urban areas. Most deliveries are completed within 1-3 hours (~70 min), while much fewer deliveries take <1hr or 4+ hrs.
* Most orders were placed in the evening (~72%), followed by mornings (~18%), and afternoons (~9%), while orders during the night are placed only between midnight and 1AM (~1%).
* The majority of orders (~89%) were delivered during the same day when the order was placed.
* Traffic strongly affects delivery times: jams increase average delivery time (~148 min), low traffic reduces it (~101 min). Most orders occur under low traffic and traffic jams, and the least under high traffic conditions.
* Weather has a smaller impact on delivery times, though deliveries are the fastest on sunny days (~104 min), while for stormy or foggy weather they are the longest (~137 min).
* Groceries are delivered the fastest, about 27 minutes on average, while for other categories the average is about 130 minutes.
* Orders placed after midnight (up to 1AM) show irregular pickup patterns, with pickup times scattered across the whole day, highlighting potential inefficiencies. There are no orders placed between 1AM and 8AM.
* About 72% of orders occur on weekdays and 28% on weekends. This highlights workload patterns for operational planning.
* Longest deliveries (~21 km) are mostly in the evening in Metropolitan and Urban areas, while shortest deliveries (~1.5 km) occur mostly in the morning.
* There were gaps in the orders of 2-3 or 11 days, across all areas. These gaps may be due to missing records or operational pauses, and because of them rolling averages weren't computed for this dataset.

### Agent Performance Insights

* Average agent age is ~30 years. Younger agents (20–30) tend to have faster average delivery times (109–115 min), while older agents (31–39) are slower (~140 min). The 15 and 50 year olds have unreliable delivery times.
* Bicycles are used only by non-rated agents (15 and 50 year olds) - while 50 year olds primarily use vans and scooters, all 15 year olds ride bicycles.
* Agents rated 4.5-5.0 have the highest number of orders (~75%), followed by agents rated 4.0-4.4 with 14%,  while all lower rated agents have less than 2% deliveries.
* Agents with lower ratings (2.5–4.4) have noticeably higher average delivery times (~165–177 min), while highly rated agents (4.5–5.0) complete deliveries much faster (~115 min), showing a strong negative correlation between rating and delivery time.
* The average agent rating stays fairly consistent around 4.58–4.68 regardless of the distance traveled, suggesting no strong correlation between distance and agent rating.
* Agents with ratings less than 3.4, as well as non-rated agents, do not perform deliveries in Semi-Urban areas, indicating that lower-rated agents are assigned only to less challenging zones.

### Geospatial Patterns Insights

* The store and delivery locations are distributed all across India.
* There are 389 store locations - few top store locations dominate the order volume with over 170 orders, while most other stores handle 30–160 orders. There are lots of stores with relatively low order numbers.
* Most dropoff locations are in metropolitan and urban areas, with 4.3K and 3.4K orders respectively, followed by 0.9K in other areas. There are only 0.1K semi-urban dropoff locations.


Overall, the efficiency is predominantly influenced by traffic, agent experience/rating, and delivery area type, with Semi-Urban zones facing the greatest challenges.

## Actionable Insights

Based on the analysis, the following recommendations can help improve Amazon delivery performance in India:

* Handling evening and rush-hour congestion: The longest delivery times are between 5:00 and 11:00 PM and during rush hours. Perhaps increasing the availability of agents and/or providing incentives during these hours would help.
* Improving after-midnight order handling (12–1 AM): Orders from 12–1 AM are usually picked up at random times, hence implementing tougher picking timelines for these orders or having another team for late night deliveries might save time.
* Leveraging highly rated agents – Agents rated between 4.5 and 5 are significantly faster and more reliable, especially on long-distance deliveries (>10 km) or during peak hours. These agents should be used for more complex deliveries.
* Targeting Semi-Urban areas – Delivery times are longer and vary more in this area. Therefore, the business should optimize the agents' coverage, store location, and routing for improved delivery services.
* Focusing on traffic -  Real-time traffic has a bigger impact on delivery times than weather, so the routes agents take should be optimized to take traffic conditions into account.
* Investing in the agents – Offer incentives or training for agents to improve their rating and performance.
