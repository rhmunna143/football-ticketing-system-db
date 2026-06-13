-- =========================================================================
-- SYSTEM: Football Ticket Booking System Database Queries DDL + DML
-- DESCRIPTION: SQL Queries for Table Creation, Data Insertion, and Data Retrieval
-- INSTRUCTIONS: 
-- =========================================================================
-- Author: @rhmunna143
-- =========================================================================
-- DROP TABLES IF THEY ALREADY EXIST TO PREVENT CONFLICTS
DROP TABLE IF EXISTS Bookings;

DROP TABLE IF EXISTS Matches;

DROP TABLE IF EXISTS Users;

-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(255) CHECK (role IN ('Football Fan', 'Ticket Manager')) DEFAULT 'Football Fan' NOT NULL,
    phone_number VARCHAR(255)
);

-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================
CREATE TABLE Matches (
    match_id SERIAL PRIMARY KEY,
    fixture VARCHAR(255) NOT NULL,
    tournament_category VARCHAR(255) NOT NULL,
    base_ticket_price INT NOT NULL CHECK (base_ticket_price >= 0),
    match_status VARCHAR(255) CHECK (
        match_status IN (
            'Available',
            'Selling Fast',
            'Sold Out',
            'Postponed'
        )
    ) DEFAULT 'Available'
);