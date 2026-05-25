-- ============================================================================
-- PROJECT: EduStaff Insight (WA Department of Education)
-- SCRIPT: 02_fact_table.sql
-- PURPOSE: Create and Populate Monthly Periodic Snapshot Fact Table
-- TARGET CRITERIA: Selection Criteria #1 (Data Modelling) & #5 (Data Management)
-- ============================================================================
-- 1. Create Workforce Periodic Snapshot Fact Table
CREATE TABLE Fact_Workforce_Snapshot (
    Snapshot_Key SERIAL PRIMARY KEY,
    Date_Key INT NOT NULL,
    -- Links to Dim_Date
    Employee_Key INT NOT NULL,
    -- Links to Dim_Employee
    District_Key INT NOT NULL,
    -- Links to Dim_School_District
    Employment_Type VARCHAR(50),
    -- Permanent Full-Time, Casual, etc.
    FTE DECIMAL(3, 2),
    -- Full-Time Equivalent fraction (e.g., 1.00, 0.60)
    Headcount INT DEFAULT 1,
    -- Multi-dimensional aggregation baseline
    -- Foreign Key Constraints to ensure 100% Referential Integrity
    CONSTRAINT fk_fact_date FOREIGN KEY (Date_Key) REFERENCES Dim_Date(Date_Key),
    CONSTRAINT fk_fact_employee FOREIGN KEY (Employee_Key) REFERENCES Dim_Employee(Employee_Key),
    CONSTRAINT fk_fact_district FOREIGN KEY (District_Key) REFERENCES Dim_School_District(District_Key)
);
-- ============================================================================
-- 2. INSERT SNAPSHOT LOGIC (Generating Month-End States)
-- ============================================================================
INSERT INTO Fact_Workforce_Snapshot (
        Date_Key,
        Employee_Key,
        District_Key,
        Employment_Type,
        FTE,
        Headcount
    )
SELECT DISTINCT d.Date_Key,
    e.Employee_Key,
    sd.District_Key,
    raw.EmploymentType,
    -- Fixed: Refactored from Employment_Type to match Python data frame
    raw.FTE,
    1 AS Headcount
FROM staging_raw_hr_data raw -- Fixed: Pointed to the correct landing pad name
    -- Join on the Dimension Tables using your clean business keys
    JOIN Dim_Employee e ON raw.EmployeeID = e.Employee_ID -- Fixed: Refactored column name to raw.EmployeeID
    JOIN Dim_School_District sd ON raw.WARegion = sd.WA_Region -- Fixed: Refactored to map with the Python region arrays
    -- Force alignment with month-end calendar dimensions for trend tracking
    JOIN Dim_Date d ON EXTRACT(
        DAY
        FROM (d.Full_Date + INTERVAL '1 day')
    ) = 1 -- Dynamically finds month end
    AND d.Calendar_Year = 2026;
-- Anchored to your 2026 reporting epoch