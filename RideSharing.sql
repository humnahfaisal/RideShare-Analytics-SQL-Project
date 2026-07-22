CREATE DATABASE rideshare;
USE rideshare;

-- CREATE TABLES

CREATE TABLE riders (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    signup_date DATE
);

CREATE TABLE drivers (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    car_type VARCHAR(30)
);

CREATE TABLE locations (
    id INT PRIMARY KEY,
    zone_name VARCHAR(50)
);

CREATE TABLE rides (
    id INT PRIMARY KEY,
    rider_id INT,
    driver_id INT,
    pickup_location_id INT,
    dropoff_location_id INT,
    fare DECIMAL(6,2),
    ride_time DATETIME,
    FOREIGN KEY (rider_id) REFERENCES riders(id),
    FOREIGN KEY (driver_id) REFERENCES drivers(id),
    FOREIGN KEY (pickup_location_id) REFERENCES locations(id),
    FOREIGN KEY (dropoff_location_id) REFERENCES locations(id)
);

CREATE TABLE ratings (
    id INT PRIMARY KEY,
    ride_id INT,
    stars INT,
    FOREIGN KEY (ride_id) REFERENCES rides(id)
);

-- INSERT VALUES

INSERT INTO riders VALUES
(1,'Ali','2024-01-05'),(2,'Sara','2024-01-10'),(3,'Ahmed','2024-01-15'),
(4,'Fatima','2024-02-01'),(5,'Bilal','2024-02-10'),(6,'Hina','2024-02-15'),
(7,'Usman','2024-02-20'),(8,'Zara','2024-03-01'),(9,'Omar','2024-03-05'),
(10,'Noor','2024-03-08'),(11,'Hassan','2024-03-10'),(12,'Ayesha','2024-03-12');

INSERT INTO drivers VALUES
(1,'Kamran','Sedan'),(2,'Rabia','Hatchback'),(3,'Faisal','SUV'),
(4,'Sana','Sedan'),(5,'Tariq','Hatchback'),(6,'Mariam','SUV');

INSERT INTO locations VALUES
(1,'DHA'),(2,'Gulberg'),(3,'Johar Town'),(4,'Model Town'),
(5,'Bahria Town'),(6,'Iqbal Town'),(7,'Wapda Town'),(8,'Cantt');

INSERT INTO rides VALUES
-- January (10 rides)
(101,1,1,1,2,450.00,'2024-01-08 08:15:00'),
(102,2,2,2,3,320.00,'2024-01-08 08:45:00'),
(103,3,3,4,5,650.00,'2024-01-09 09:00:00'),
(104,4,1,1,3,500.00,'2024-01-10 18:20:00'),
(105,5,2,3,1,280.00,'2024-01-11 19:10:00'),
(106,6,4,6,7,390.00,'2024-01-12 08:30:00'),
(107,1,3,2,4,410.00,'2024-01-15 08:10:00'),
(108,7,5,7,8,340.00,'2024-01-16 20:15:00'),
(109,2,1,1,2,460.00,'2024-01-18 08:20:00'),
(110,8,2,3,5,380.00,'2024-01-20 17:45:00'),

-- February (10 rides)
(111,3,1,4,1,700.00,'2024-02-01 08:05:00'),
(112,4,3,5,6,520.00,'2024-02-02 18:30:00'),
(113,9,4,6,2,470.00,'2024-02-03 08:50:00'),
(114,1,1,1,3,440.00,'2024-02-05 08:15:00'),
(115,5,6,8,4,610.00,'2024-02-06 19:20:00'),
(116,10,2,2,7,350.00,'2024-02-08 09:00:00'),
(117,6,5,6,5,480.00,'2024-02-09 18:00:00'),
(118,2,3,2,1,420.00,'2024-02-10 08:40:00'),
(119,11,1,3,8,530.00,'2024-02-12 20:00:00'),
(120,3,4,4,3,390.00,'2024-02-14 08:25:00'),

-- March (10 rides)
(121,2,2,2,3,330.00,'2024-03-01 08:15:00'),
(122,5,1,1,2,450.00,'2024-03-01 08:45:00'),
(123,9,4,6,7,400.00,'2024-03-02 18:20:00'),
(124,3,3,4,5,650.00,'2024-03-02 19:00:00'),
(125,1,1,1,3,500.00,'2024-03-03 08:10:00'),
(126,7,6,7,8,340.00,'2024-03-03 20:00:00'),
(127,10,2,2,1,460.00,'2024-03-04 08:25:00'),
(128,6,5,6,4,390.00,'2024-03-04 17:40:00'),
(129,11,3,3,5,520.00,'2024-03-05 08:15:00'),
(130,8,4,4,6,410.00,'2024-03-05 18:50:00');

-- Generates a random-but-realistic star rating (3-5) for every ride

INSERT INTO ratings
SELECT id, id, FLOOR(3 + RAND()*3)
FROM rides;

SELECT COUNT(*) FROM rides;

-- BUSIEST HOURS (GROUPING ACCORDING TO TIME

SELECT HOUR(ride_time) AS hour_of_day, COUNT(*) AS total_rides
FROM rides
GROUP BY HOUR(ride_time)
ORDER BY total_rides DESC;

-- HIGH DEMAND LOCATIONS

SELECT l.zone_name, COUNT(*) AS total_pickups
FROM rides r
JOIN locations l ON r.pickup_location_id = l.id
GROUP BY l.zone_name
ORDER BY total_pickups DESC;

-- MONTHLY GROWTH (TREND)

SELECT DATE_FORMAT(ride_time, '%Y-%m') AS month, COUNT(*) AS total_rides,
       SUM(fare) AS total_revenue
FROM rides
GROUP BY DATE_FORMAT(ride_time, '%Y-%m')
ORDER BY month;

-- DRIVER LEADERBOARD

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

-- RIDER BEHAVIOUR (Most Loyal/Frequent Riders)

SELECT ri.name AS rider_name, COUNT(r.id) AS total_rides,
       SUM(r.fare) AS total_spent,
       ROUND(AVG(r.fare), 2) AS avg_fare_per_ride
FROM riders ri
JOIN rides r ON ri.id = r.rider_id
GROUP BY ri.name
ORDER BY total_rides DESC;

-- WEEKDAYS VS WEEKENDS RIDES (CASE WHEN)

SELECT 
    CASE 
        WHEN DAYOFWEEK(ride_time) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_rides,
    ROUND(AVG(fare), 2) AS avg_fare
FROM rides
GROUP BY day_type;

-- AVERAGE RATING OF EVERY DRIVER

SELECT d.name AS driver_name,COUNT(rt.id) AS total_ratings,
       ROUND(AVG(rt.stars), 2) AS avg_rating
FROM drivers d
JOIN rides r ON d.id = r.driver_id
JOIN ratings rt ON r.id = rt.ride_id
GROUP BY d.name
ORDER BY avg_rating DESC;

-- PEAK ZONE BY HOUR
WITH hourly_zone_counts AS (
    SELECT HOUR(r.ride_time) AS hour_of_day, l.zone_name, COUNT(*) AS ride_count,
           ROW_NUMBER() OVER (
               PARTITION BY HOUR(r.ride_time) 
               ORDER BY COUNT(*) DESC
           ) AS rn
    FROM rides r
    JOIN locations l ON r.pickup_location_id = l.id
    GROUP BY HOUR(r.ride_time), l.zone_name
)
SELECT hour_of_day, zone_name, ride_count
FROM hourly_zone_counts
WHERE rn = 1
ORDER BY hour_of_day;