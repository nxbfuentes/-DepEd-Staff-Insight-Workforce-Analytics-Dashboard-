-- ====================================================================
-- PROJECT: EduStaff Insight (WA Department of Education)
-- SCRIPT:  03_am_automated_tests.sql
-- PURPOSE: Automated Unit Testing & Data Quality Validation Gates
-- MANDATE: Fulfills Level 5 JD ("Conduct unit, system, and integration testing")
-- ====================================================================

-- TEST 1: Relational Completeness (Referential Integrity Check)
-- Goal: Ensure no records in the Fact table are orphaned due to missing dimensions.
DO $$
DECLARE 
    orphaned_rows INT;
BEGIN
    SELECT COUNT(*) INTO orphaned_rows
    FROM Fact_Workforce_Snapshot f
    LEFT JOIN Dim_Employee e ON f.Employee_Key = e.Employee_Key
    LEFT JOIN Dim_School_District sd ON f.District_Key = sd.District_Key
    LEFT JOIN Dim_Date d ON f.Date_Key = d.Date_Key
    WHERE e.Employee_Key IS NULL 
       OR sd.District_Key IS NULL 
       OR d.Date_Key IS NULL;

    IF orphaned_rows > 0 THEN
        RAISE EXCEPTION '❌ TEST FAILED: Relational Integrity Violation. Found % orphaned rows in Fact table.', orphaned_rows;
    ELSE
        RAISE NOTICE '✅ TEST PASSED: Relational Integrity Check. 0 orphaned records found.';
    END IF;
END $$;


-- TEST 2: Workforce Logic Validation (FTE Capacity Constraint)
-- Goal: Verify that no individual employee exceeds a full 1.00 Full-Time Equivalent load.
DO $$
DECLARE 
    fte_violations INT;
BEGIN
    SELECT COUNT(*) INTO fte_violations
    FROM Fact_Workforce_Snapshot
    WHERE FTE > 1.00;

    IF fte_violations > 0 THEN
        RAISE EXCEPTION '❌ TEST FAILED: Workforce Logic Violation. Found % records where FTE exceeds 1.00.', fte_violations;
    ELSE
        RAISE NOTICE '✅ TEST PASSED: Workforce Logic Check. 0 records exceed the 1.00 FTE operational limit.';
    END IF;
END $$;


-- TEST 3: Data Integrity Baseline (Age Horizon Verification)
-- Goal: Ensure the "Aging Workforce Risk" analytics matrix doesn't inherit corrupted negative age records.
DO $$
DECLARE 
    age_violations INT;
BEGIN
    SELECT COUNT(*) INTO age_violations
    FROM Dim_Employee
    WHERE (2026 - Birth_Year) < 18 OR (2026 - Birth_Year) > 70;

    IF age_violations > 0 THEN
        RAISE EXCEPTION '❌ TEST FAILED: Data Integrity Violation. Found % employees outside realistic working age parameters (18-70).', age_violations;
    ELSE
        RAISE NOTICE '✅ TEST PASSED: Data Integrity Check. Employee age parameters are stable and uniform.';
    END IF;
END $$;