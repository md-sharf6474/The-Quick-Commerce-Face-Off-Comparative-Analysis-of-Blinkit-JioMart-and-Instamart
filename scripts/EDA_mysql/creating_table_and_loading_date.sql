#creating the database
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

# creating table 
CREATE TABLE ecommerce(
order_id VARCHAR(50) PRIMARY KEY,
customer_id VARCHAR(50),
platform VARCHAR(20),
delivery_time_minutes INT,
product_category VARCHAR(50),
order_value INT,
customer_feedback VARCHAR(50),
service_rating INT,
delivery_delay VARCHAR(10),
refund_requested VARCHAR(50),
order_date DATE
);

#loading data 
LOAD DATA LOCAL INFILE "C:\\Users\\sharf\\OneDrive\\Desktop\\blinkit,swiggy and jio project\\clean_ecommerce_data.xls"
INTO TABLE ecommerce
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 ROWS;