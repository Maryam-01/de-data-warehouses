DROP DATABASE IF EXISTS ncstaffsql;
CREATE DATABASE ncstaffsql;
DROP TABLE IF EXISTS staff_performance CASCADE;
DROP TABLE IF EXISTS dim_staff CASCADE;
DROP TABLE IF EXISTS dim_location CASCADE;
DROP TABLE IF EXISTS dim_manager CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS staff CASCADE;


\c ncstaffsql

CREATE TABLE staff
(
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    area VARCHAR(50),
    course VARCHAR(100),
    manager VARCHAR(50),
    mentees INT,
    next_cohort_date TEXT,
    mentees_staff_rating INT,
    daily_rate FLOAT,
    revenue FLOAT
);

INSERT INTO staff 
    (first_name, last_name, area, course, manager, mentees, next_cohort_date, mentees_staff_rating, daily_rate, revenue)
VALUES 
('Alex', 'Swain', 'Remote', 'Data', 'Joe Mulvey', 11, '12 January 2024', 10, 700.98, 9112.74),
('Stephen', 'Corke', 'Manchester', 'Software', 'Paul Rogerson', 0, '24 February 2024', 8, 600.28, 7803.64),
('Verity', 'Gregory', 'Remote', 'Software', 'Stephen Corke', 13, '24 March 2024', 9, 578.26, 7517.38),
('Simon', 'Jackson', 'Leeds', 'Data', 'Alex Swain', 18, '12 January 2024', 2, 12.99, 168.87),
('Paul', 'Copley', 'Manchester', 'Data', 'Paul Rogerson', 0, '12 May 2024', 9, 699.00, 9087.00),
('Paul', 'Rogerson', 'Manchester', 'Software', 'Sam Caine', 0, '24 June 2024', 4, 150.01, 1950.13),
('John', 'Hutcheon', 'Manchester', 'Software', 'August Aldred', 9, '24 July 2024', 7, 200.67, 2608.71),
('Jodie', 'Cheung', 'Manchester', 'Software', 'August Aldred', 9, '24 August 2024', 7, 400.05, 5200.65),
('Pippa', 'Austin', 'Manchester', 'Software', 'August Aldred', 10, '13 April 2024', 8, 400.04, 5200.52),
('Bela', 'Bertalan', 'Manchester', 'Software', 'August Aldred', 11, '17 October 2024', 6, 370.89, 4821.57),
('Emily', 'Bennett', 'Manchester', 'Cloud', 'James Heggs', 6, '03 November 2024', 7, 550.35, 7154.55),
('Mezz', 'Davies', 'Leeds', 'Software', 'David Bartlett', 12, '17 December 2024', 7, 548.33, 7128.29),
('Danika', 'Crawley', 'Manchester', 'Data', 'Joe Mulvey', 8, '12 May 2024', 9, 698.99, 9086.87),
('August', 'Aldred', 'Manchester', 'Software', 'Paul Rogerson', 13, '24 August 2024', 8, 439.09, 5708.17),
('Lee', 'Kirkham', 'Leeds', 'Software', 'David Bartlett', 14, '17 January 2024', 5, 421.89, 5484.57),
('Hev', 'Magnier-Ashton', 'Manchester', 'Software', 'Rose Mullan', 9, '17 January 2024', 5, 511.45, 6648.85),
('Eli', 'Wiggins', 'Manchester', 'Cloud', 'James Heggs', 11, '03 March 2024', 8, 588.88, 7655.44),
('Kyle', 'McPhail', 'Manchester', 'Data', 'Joe Mulvey', 7, '12 January 2024', 5, 199.99, 2599.87),
('Katherine', 'Hurst', 'Manchester', 'Software', 'Stephen Corke', 10, '13 April 2024', 8, 665.35, 8649.55),
('David', 'Bartlett', 'Leeds', 'Software', 'Rose Mullan', 2, '13 April 2024', 3, 89.98, 1709.62),
('Chon', 'Lee', 'Manchester', 'Data', 'Joe Mulvey', 15, '12 May 2024', 4, 50.67, 658.71);

SELECT * FROM staff;

CREATE TABLE dim_staff 
(
    staff_id SERIAL PRIMARY KEY,
    staff_first_name VARCHAR(100),
    staff_last_name VARCHAR(100)
    
);

CREATE TABLE dim_location
(
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(100)
    
);




CREATE TABLE dim_manager (
    manager_id SERIAL PRIMARY KEY,
    manager_name VARCHAR(100)

);


CREATE TABLE dim_date 
(
    date_id SERIAL PRIMARY KEY,
    full_date DATE,
    day INT,
    day_name VARCHAR(100),
    week INT,
    month INT,
    month_name VARCHAR(100),
    quarter INT,
    year INT
);


CREATE TABLE staff_performance
(   
    fact_id SERIAL PRIMARY KEY,
    staff_id INT REFERENCES dim_staff(staff_id) ,
    date_id INT REFERENCES dim_date(date_id),
    location_id INT REFERENCES dim_location(location_id),
    manager_id INT REFERENCES dim_manager(manager_id),
    mentees INT,
    mentees_staff_rating INT,
    daily_rate NUMERIC(10,2),
    revenue NUMERIC(10,2)


);



INSERT INTO dim_staff (
    staff_first_name, staff_last_name) 
    SELECT DISTINCT
    first_name,
    last_name
FROM staff;
SELECT * FROM dim_staff;


INSERT INTO dim_location (
   location_name) 
    SELECT DISTINCT
    area
FROM staff;
SELECT * FROM dim_location;

INSERT INTO dim_manager (manager_name)
SELECT DISTINCT
manager
FROM staff;
SELECT * FROM dim_manager;

INSERT INTO dim_date (full_date, day, day_name, week, month, month_name, quarter, year)

WITH converted_dates AS (
    SELECT DISTINCT TO_DATE(next_cohort_date, 'DD Month YYYY') AS full_date
    FROM staff
)
SELECT 
full_date,
EXTRACT(DAY FROM full_date) AS day,
TO_CHAR(full_date, 'FMDay') AS day_name,
EXTRACT(WEEK FROM full_date) AS week,
EXTRACT(MONTH FROM full_date) AS month,
TO_CHAR(full_date, 'FMMonth') AS month_name,
EXTRACT(QUARTER FROM full_date) AS quarter,
EXTRACT(YEAR FROM full_date) AS year

FROM converted_dates;



INSERT INTO staff_performance (
    staff_id,
    date_id,
    location_id,
    manager_id,
    mentees,
    mentees_staff_rating,
    daily_rate,
    revenue
)

SELECT  
        ds.staff_id,
        dd.date_id,
        dl.location_id,
        dm.manager_id,
        s.mentees,
        s.mentees_staff_rating,
        s.daily_rate,
        s.revenue
FROM staff s

JOIN dim_staff ds
        ON s.first_name = ds.staff_first_name AND s.last_name = ds.staff_last_name

JOIN dim_location dl ON s.area = dl.location_name
JOIN dim_manager dm ON s.manager = dm.manager_name

JOIN dim_date dd ON TO_DATE(s.next_cohort_date, 'DD Month YYYY' ) = dd.full_date;


SELECT 
staff_performance.mentees_staff_rating,
dim_manager.manager_name

FROM staff_performance
JOIN dim_manager ON dim_manager.manager_id = staff_performance.manager_id
WHERE staff_performance.mentees_staff_rating = (SELECT MIN(mentees_staff_rating) FROM staff_performance);


SELECT * FROM staff_performance;











