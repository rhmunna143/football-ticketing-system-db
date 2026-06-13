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

-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE Bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT,
    match_id INT,
    seat_number VARCHAR(255),
    payment_status VARCHAR(255),
    total_cost INT NOT NULL,
    -- Foreign Key
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users (user_id),
    CONSTRAINT fk_match FOREIGN KEY (match_id) REFERENCES matches (match_id),
    -- Check
    CONSTRAINT chk_payment_status CHECK (
        payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')
    ),
    CONSTRAINT chk_total_cost CHECK (total_cost >= 0)
);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO
    Users (full_name, email, role, phone_number)
VALUES
    (
        'Tanvir Rahman',
        'tanvir@mail.com',
        'Football Fan',
        '+8801711111111'
    ),
    (
        'Asif Haque',
        'asif@mail.com',
        'Football Fan',
        '+8801722222222'
    ),
    (
        'Sajjad Rahman',
        'sajjad@mail.com',
        'Ticket Manager',
        '+8801733333333'
    ),
    (
        'Jannat Ara',
        'jannat@mail.com',
        'Football Fan',
        NULL
    );

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO
    Matches (
        match_id,
        fixture,
        tournament_category,
        base_ticket_price,
        match_status
    )
VALUES
    (
        101,
        'Real Madrid vs Barcelona',
        'Champions League',
        150.00,
        'Available'
    ),
    (
        102,
        'Man City vs Liverpool',
        'Premier League',
        120.00,
        'Selling Fast'
    ),
    (
        103,
        'Bayern Munich vs PSG',
        'Champions League',
        130.00,
        'Available'
    ),
    (
        104,
        'AC Milan vs Inter Milan',
        'Serie A',
        90.00,
        'Sold Out'
    ),
    (
        105,
        'Juventus vs Roma',
        'Serie A',
        80.00,
        'Available'
    );

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO
    Bookings (
        booking_id,
        user_id,
        match_id,
        seat_number,
        payment_status,
        total_cost
    )
VALUES
    (501, 1, 101, 'A-12', 'Confirmed', 150.00),
    (502, 1, 102, 'B-04', 'Confirmed', 120.00),
    (503, 2, 101, 'A-13', 'Confirmed', 150.00),
    (504, 2, 101, NULL, NULL, 150.00),
    (505, 3, 102, 'C-20', 'Pending', 120.00);

-- ====================
-- Queries (Part - 2)
-- ====================
-- Query 1: Retrieve all upcoming football matches belonging to the 'Champions League' where the match status is 'Available'.
SELECT
    match_id,
    fixture,
    base_ticket_price
FROM
    matches
WHERE
    tournament_category = 'Champions League'
    AND match_status = 'Available';

-- Query 2: Search for all users whose full names start with 'Tanvir' or contain the phrase 'Haque' (case-insensitive).
SELECT
    user_id,
    full_name,
    email
FROM
    users
WHERE
    (
        full_name ILIKE 'Tanvir%'
        OR full_name ILIKE '%Haque%'
    );