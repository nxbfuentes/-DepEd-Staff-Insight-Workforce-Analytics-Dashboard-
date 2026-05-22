-- ==============================================================================
-- PROJECT: EduStaff Insight (WA Department of Education)
-- COMPONENT: /tests/unit_tests/03_am_automated_tests.sql
-- OBJECTIVE: Validate Data Quality, Relational Integrity, and Business Logic
-- TARGET: Selection Criteria #5 (Data Management & Quality Assurance)
-- ==============================================================================

BEGIN;

-- ------------------------------------------------------------------------------
-- TEST 1: Relational Completeness (Referential Integrity Check)
-- Goal: Ensure zero records in the Fact table are orphaned due to missing dimensions.
-- ------------------------------------------------------------------------------
DO $$
DECLARE
    orphaned_records INT;
BEGIN
    SELECT COUNT(*)
    INTO orphaned_records
    FROM Fact_Workforce_Snapshot f
    LEFT JOIN Dim_Employee e ON f.Employee_Key = e.Employee_Key
    LEFT JOIN Dim_School_District d ON f.District_Key = d.District_Key
    LEFT JOIN Dim_Date dt ON f.Date_Key = dt.Date_Key
    WHERE e.Employee_Key IS NULL 
       OR d.District_Key IS NULL 
       OR dt.Date_Key IS NULL;

    IF orphaned_records > 0 THEN
        RAISE EXCEPTION 'TEST 1 FAILED: % orphaned records detected in Fact table. Referential integrity breached!', orphaned_records;
    ELSE
        RAISE NOTICE 'TEST 1 PASSED: Referential integrity is rock-solid. Zero orphaned records.';
    END IF;
END $$;


-- ------------------------------------------------------------------------------
-- TEST 2: Workforce Logic Validation (FTE vs. Headcount Constraint)
-- Goal: Enforce public sector rule that no individual employee load exceeds 1.00 FTE.
-- ------------------------------------------------------------------------------
DO $$
DECLARE
    fte_violations INT;
BEGIN
    SELECT COUNT(*)
    INTO fte_violations
    FROM Fact_Workforce_Snapshot
    WHERE FTE > 1.00;

    IF fte_violations > 0 THEN
        RAISE EXCEPTION 'TEST 2 FAILED: % records found violating the max load rule (FTE > 1.00)!', fte_violations;
    ELSE
        RAISE NOTICE 'TEST 2 PASSED: Employee resource constraints valid. Zero FTE violations.';
    END IF;
END $$;


-- ------------------------------------------------------------------------------
-- TEST 3: Data Integrity Boundary Check (Age Anomaly Matrix)
-- Goal: Ensure our "Aging Workforce Risk" metrics do not inherit corrupted birth years.
-- ------------------------------------------------------------------------------
DO $$
DECLARE
    age_violations INT;
BEGIN
    -- Validates that birth years represent realistic active staff (e.g., age between 15 and 85)
    SELECT COUNT(*)
    INTO age_violations
    FROM Dim_Employee
    WHERE Birth_Year > 2011 OR Birth_Year < 1941;

    IF age_violations > 0 THEN
        RAISE EXCEPTION 'TEST 3 FAILED: % employee profiles contain out-of-bounds birth years!', age_violations;
    ELSE
        RAISE NOTICE 'TEST 3 PASSED: Demographic age parameters are fully realistic for workforce analysis.';
    END IF;
END $$;

COMMIT;