-- ============================================================================
-- 1. CREATE WORKFORCE PERIODIC SNAPSHOT FACT TABLE
-- ============================================================================
CREATE TABLE Fact_Workforce_Snapshot (
    Snapshot_Key SERIAL PRIMARY KEY,
    Date_Key INT NOT NULL,               -- Links to Dim_Date
    Employee_Key INT NOT NULL,           -- Links to Dim_Employee
    District_Key INT NOT NULL,           -- Links to Dim_School_District
    Employment_Type VARCHAR(50),         -- Permanent, Fixed-Term, Casual
    FTE DECIMAL(3, 2),                   -- Full-Time Equivalent (e.g., 1.00, 0.60)
    Headcount INT DEFAULT 1,             -- Always 1 for an active individual record
    
    -- Foreign Key Constraints to ensure Referential Integrity
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
SELECT DISTINCT
    d.Date_Key,
    e.Employee_Key,
    sd.District_Key,
    raw.Employment_Type,
    raw.FTE,
    1 AS Headcount
FROM Staging_Raw_HR_Data raw
-- Join on the Dimension Tables using your clean business keys
JOIN Dim_Employee e 
    ON raw.Employee_ID = e.Employee_ID
JOIN Dim_School_District sd 
    ON raw.School_Name = sd.School_Name 
    AND raw.Regional_District = sd.Regional_District
-- Force alignment with month-end calendar dimensions for trend tracking
JOIN Dim_Date d 
    ON d.Is_Month_End = TRUE 
    AND d.Calendar_Year = 2026; -- Anchored to your 2026 reporting epoch