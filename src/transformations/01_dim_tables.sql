-- ====================================================================
-- PROJECT: EduStaff Insight (WA Department of Education)
-- SCRIPT: 01_dim_tables.sql
-- PURPOSE: Build Dimensions for Demographics, Districts, and Time
-- TARGET CRITERIA: Selection Criteria #1 (Data Modelling) & #5 (Data Management)
-- ====================================================================

-- 1. Create Regional Schooling Districts Dimension
CREATE TABLE Dim_School_District (
    District_Key INT PRIMARY KEY,
    School_Name VARCHAR(100),
    Regional_District VARCHAR(100) -- e.g., Pilbara, Kimberley, Metro
);

INSERT INTO Dim_School_District (District_Key, School_Name, Regional_District)
SELECT DISTINCT 
    DENSE_RANK() OVER (ORDER BY School_Name, Regional_District) AS District_Key,
    School_Name,
    Regional_District
FROM Staging_Raw_HR_Data;


-- 2. Create Employee Profile Dimension (Capturing Equity and Demographics)
CREATE TABLE Dim_Employee (
    Employee_Key INT PRIMARY KEY,
    Employee_ID VARCHAR(20),
    Role_Title VARCHAR(100), -- Teacher, Principal, Admin
    Gender VARCHAR(20),
    Indigenous_Identity VARCHAR(5), -- Yes/No
    Disability_Status VARCHAR(5),   -- Yes/No
    Birth_Year INT
);

INSERT INTO Dim_Employee (Employee_Key, Employee_ID, Role_Title, Gender, Indigenous_Identity, Disability_Status, Birth_Year)
SELECT DISTINCT
    DENSE_RANK() OVER (ORDER BY Employee_ID) AS Employee_Key,
    Employee_ID,
    Role_Title,
    Gender,
    Indigenous_Identity,
    Disability_Status,
    -- FIX: Anchored to 2026 to guarantee unchanging workforce telemetry history
    2026 - Age AS Birth_Year 
FROM Staging_Raw_HR_Data;


-- 3. Create Calendar Dimension for Workforce Trend Tracking
CREATE TABLE Dim_Date (
    Date_Key INT PRIMARY KEY,       -- Format: YYYYMMDD (e.g., 20260522)
    Full_Date DATE NOT NULL,
    Calendar_Year INT NOT NULL,
    Calendar_Month INT NOT NULL,
    Month_Name VARCHAR(20) NOT NULL,
    Calendar_Quarter INT NOT NULL,
    School_Term VARCHAR(10)         -- Crucial for WA public school seasonal filtering
);

-- Populating Dim_Date using PostgreSQL series generation (2020 to 2030)
INSERT INTO Dim_Date (Date_Key, Full_Date, Calendar_Year, Calendar_Month, Month_Name, Calendar_Quarter, School_Term)
SELECT 
    TO_CHAR(datum, 'YYYYMMDD')::INT AS Date_Key,
    datum AS Full_Date,
    EXTRACT(YEAR FROM datum) AS Calendar_Year,
    EXTRACT(MONTH FROM datum) AS Calendar_Month,
    TO_CHAR(datum, 'TMMonth') AS Month_Name,
    EXTRACT(QUARTER FROM datum) AS Calendar_Quarter,
    CASE 
        WHEN EXTRACT(MONTH FROM datum) IN (2, 3, 4) THEN 'Term 1'
        WHEN EXTRACT(MONTH FROM datum) IN (5, 6, 7) THEN 'Term 2'
        WHEN EXTRACT(MONTH FROM datum) IN (8, 9, 10) THEN 'Term 3'
        ELSE 'Term 4'
    END AS School_Term
FROM generate_series(
    '2020-01-01'::DATE, 
    '2030-12-31'::DATE, 
    '1 day'::INTERVAL
) datum;