DROP TABLE IF EXISTS Staging_Raw_HR_Data;
CREATE TABLE Staging_Raw_HR_Data (
    EmployeeID VARCHAR(20),
    Gender VARCHAR(20),
    Age INT,
    IndigenousIdentity VARCHAR(5),
    DisabilityStatus VARCHAR(5),
    Role VARCHAR(100),
    WARegion VARCHAR(100),
    EmploymentType VARCHAR(50),
    Status VARCHAR(20),
    CommencementDate DATE,
    SeparationDate DATE,
    FTE NUMERIC(3, 1)
);