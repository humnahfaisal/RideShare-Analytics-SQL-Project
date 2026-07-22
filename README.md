🚗 RideShare-Analytics-SQL-Project

A ride-sharing platform (Uber/Careem-style) modeled entirely in SQL, built to answer the operational questions a real ride-sharing company tracks every day: when are we busiest, which zones have the highest demand, which drivers are top performers, and how is the platform growing month over month.

This project was built from scratch; schema design, sample data, and every query, as a hands-on way to practice time-based analysis, multi-table joins, and window functions on a dataset with a real geospatial dimension.

🧠 Why This Project

Ride-sharing data is a great sandbox for SQL practice because every trip carries three dimensions at once, a person, a location, and a time, which naturally leads to grouping, ranking, and trend queries that mirror real operations dashboards, the kind used for driver incentives, surge pricing, and city-expansion decisions.

🗂️ Database Schema

The database consists of 5 interconnected tables:

Table	Description
riders	People who book rides
drivers	People who drive for the platform
locations	Named zones/areas such as DHA, Gulberg, Johar Town
rides	Each trip, rider, driver, pickup zone, dropoff zone, fare, timestamp
ratings	Star rating from 1 to 5 left for each completed ride

Entity Relationship Overview

riders connect to rides, rides connect to drivers
rides also connect to locations twice, once for pickup and once for dropoff
rides connect to ratings

One rider can have many rides, one driver can have many rides
Each ride references locations twice, once for pickup and once for dropoff, similar to a self-referencing relationship but pointing to a different table instead of itself
Each ride has one rating

⚙️ Tech Stack

Database: MySQL
Dataset size: 12 riders, 6 drivers, 8 zones, 30 rides across 3 months from January to March 2024, 30 ratings
Concepts used: Multi-table joins, aggregate functions, date and time functions, CASE WHEN, CTEs, window functions

🚀 How to Run This Project

Clone this repository
Open rideshare_project.sql in MySQL Workbench or any MySQL client
Run the script top to bottom, it will create the database, all 5 tables, insert sample data, and generate realistic ratings automatically for every ride

mysql -u your_username -p < rideshare_project.sql

🔍 Key Analyses

The full script contains all core and bonus queries with detailed comments. A few highlights:

Driver Leaderboard, CTE plus Window Function
Sums total earnings per driver across all their completed rides, then ranks every driver from most to least earnings using RANK.

WITH driver_earnings AS (
    SELECT d.name AS driver_name,
           COUNT(r.id) AS total_rides,
           SUM(r.fare) AS total_earnings
    FROM drivers d
    JOIN rides r ON d.id = r.driver_id
    GROUP BY d.name
)
SELECT driver_name, total_rides, total_earnings,
       RANK() OVER (ORDER BY total_earnings DESC) AS earnings_rank
FROM driver_earnings;

Peak Zone Per Hour, CTE plus ROW_NUMBER and PARTITION BY
Finds the single most popular pickup zone for each hour of the day independently, a local maximum per group pattern.

WITH hourly_zone_counts AS (
    SELECT HOUR(r.ride_time) AS hour_of_day,
           l.zone_name,
           COUNT(*) AS ride_count,
           ROW_NUMBER() OVER (
               PARTITION BY HOUR(r.ride_time) ORDER BY COUNT(*) DESC
           ) AS rn
    FROM rides r
    JOIN locations l ON r.pickup_location_id = l.id
    GROUP BY HOUR(r.ride_time), l.zone_name
)
SELECT hour_of_day, zone_name, ride_count
FROM hourly_zone_counts
WHERE rn = 1
ORDER BY hour_of_day;

See rideshare_project.sql for the remaining queries: busiest hours, high-demand zones, monthly growth trend, rider loyalty and spend, weekday versus weekend demand, and average rating per driver.

🧩 SQL Concepts Demonstrated

Multi-table joins, including a table referenced twice for two different roles, pickup and dropoff location
Aggregate functions such as COUNT, SUM, and AVG with GROUP BY
Date and time functions including HOUR, DAYOFWEEK, and DATE_FORMAT
CASE WHEN for bucketing and categorization
Common Table Expressions with WITH
Window functions including RANK, ROW_NUMBER, and PARTITION BY
Randomized but realistic sample data generation using RAND and FLOOR

📈 Sample Insights From the Data

Peak hours cluster around the 8 to 9 AM and 6 to 8 PM windows, mirroring real-world commute patterns
Certain zones such as DHA and Gulberg consistently rank as the top pickup points
Ride volume and revenue increase from January through March
The top driver is ranked by total earnings rather than ride count, rewarding higher-value trips
The most in-demand pickup zone shifts across different hours of the day

📁 Repository Structure

rideshare_project.sql, full schema, sample data, and all queries
README.md, this file

👤 Author

Built as a self-guided SQL learning project, applying joins, CTEs, and window functions to a realistic operational dataset.
