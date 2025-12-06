-- Create a database
CREATE DATABASE IF NOT EXISTS PortfolioProject;
USE PortfolioProject;

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    Order_ID VARCHAR(50) PRIMARY KEY,
    Store_Latitude DOUBLE NULL,
    Store_Longitude DOUBLE NULL,
    Drop_Latitude DOUBLE NULL,
    Drop_Longitude DOUBLE NULL,
    Order_Date DATE NULL,
    Order_Time TIME NULL,
    Pickup_Time TIME NULL,
    Area VARCHAR(50) NULL,
    Category VARCHAR(50) NULL,
    Delivery_Time INT NULL,
    Weather VARCHAR(50) NULL,
    Traffic VARCHAR(50) NULL,
    Vehicle VARCHAR(50) NULL
);

-- Create agents table
CREATE TABLE IF NOT EXISTS agents (
    Order_ID VARCHAR(50) PRIMARY KEY,
    Agent_Age INT NULL,
    Agent_Rating DECIMAL(2,1) NULL,
    FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID)
);