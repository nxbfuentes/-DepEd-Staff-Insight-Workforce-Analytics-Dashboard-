## 📋 Executive Briefing Note: DepEdStaff Insight Pipeline Architecture

---

### 🏛️ Strategic Alignment Context

This repository serves as a fully auditable, enterprise-grade data engineering and business intelligence solution designed explicitly for the **Workforce Policy and Coordination Directorate** within the **WA Department of Education**.

To directly fulfill the mandate of the **Level 5 Business Intelligence Analyst** position (Position #00027081) and address the evaluation metrics of the **Level 8 Manager of Workforce Planning**, this pipeline moves past generic corporate sales frameworks. Instead, it focuses heavily on public-sector human resource analytics, tracking regional schooling boundary capacity metrics , whole-of-government equity benchmarks , and longitudinal workforce stability.

---

## 🏗️ Repository Directory Architecture

To satisfy **Selection Criteria #5 (Data Management)** , this repository enforces a production-ready, highly maintainable separation of concerns. Code assets are not lumped together ; they are partitioned into functional directories that mirror modern analytics engineering environments:

```text
edustaff-insight-bi/
├── .github/
│   └── pull_request_template.md     # Governance documentation constraints
├── src/
│   ├── data_generation/
│   │   ├── mock_data_generator.py   # Vectorized Python telemetry generator
│   │   └── raw_workforce_data.csv   # Landing-pad baseline dataset (5,000 rows)
│   └── transformations/
│       ├── 01_dim_tables.sql        # Master Dimension DDL & Series Logic
│       └── 02_fact_table.sql        # Monthly Periodic Snapshot Fact DDL
├── tests/
│   └── unit_tests/
│       └── 03_am_automated_tests.sql # Multi-layer database verification gates
├── reporting/
│   └── EduStaff_Workforce_Model.pbix # Production Power BI compilation file
└── README.md                        # Root tactical portfolio briefing note

```

---

## 🛠️ Data Pipeline Lifecycle Execution Flow

-> *A visual node map tracing data flow: Python Generator Engine ──► CSV Ingestion ──► Local PostgreSQL Staging ──► Star Schema Dimensions & Periodic Snapshot Fact Table ──► Automated SQL Unit Testing Gates ──► Secure Power BI Import Connection.*

### 🚀 Phase 1: Vectorized Data Synthesis Engine

*  **Asset Location:** `src/data_generation/mock_data_generator.py` 


*  **Technical Mechanisms:** Utilizes `numpy` and `pandas` to generate an uncorrupted, statistically balanced baseline profile of **5,000 unique public-sector employees**.


*  **Domain Controls:** Ages are modeled using a normal distribution ($\mu=44, \sigma=12$) bounded tightly between 21 and 67 to simulate an authentic "Aging Workforce" trend line. Historical attrition modeling operates via stochastic evaluation rules to generate a stable 15% baseline resignation profile, alongside heightened exit probabilities for staff $\ge 60$ to track retirement vulnerabilities.


### 📐 Phase 2: Relational Star Schema Optimization

* **Asset Location:** `src/transformations/` 


* **Architectural Strategy:** To excel in **Selection Criteria #1 (Data Modelling)** , the flat source file is structurally normalized into an optimized Star Schema database layer rather than loaded raw. This isolates descriptive criteria from volatile transactional tracking measures.


#### 1. `01_dim_tables.sql` (Descriptive Context Fields)

* **`Dim_Employee`**: Captures slowly changing socioeconomic and corporate profiles (Gender, Indigenous Identity, Disability Status).


> 
> **Meticulous Polish:** To prevent server-time drift from breaking historical telemetry when scripts are executed in future cycles, birth years are statically anchored to an immutable **2026 reporting epoch** ($2026 - \text{Age}$).
> 
> 


* **`Dim_School_District`**: Groups educational assets across broad Western Australian administrative schooling boundaries (e.g., Pilbara, Kimberley, Goldfields) for geographic capability profiling.


* **`Dim_Date`**: Generates a continuous, gapless calendar timeline using a PostgreSQL `generate_series()` spanning 2020–2030. Includes specialized conditional evaluations for Western Australian **School Terms (Terms 1–4)** to smoothly filter seasonal contract variations.



#### 2. `02_fact_table.sql` (Analytical Snapshot Layer)
* **`Fact_Workforce_Snapshot`**: Implements a highly performant **Monthly Periodic Snapshot Model**. Rather than using single daily transaction logs, it utilizes a sophisticated month-end extraction join:



$$\text{EXTRACT(DAY FROM (d.Full_Date + INTERVAL '1 day'))} = 1$$


This captures the absolute state of every active and exiting staff asset at the final tick of each calendar month. It maintains explicit foreign key constraints to force strict database relational integrity.



---

## 🧪 Rigorous Automated Quality Testing Framework

* **Asset Location:** `tests/unit_tests/03_am_automated_tests.sql` 



To target the Level 5 job requirement to **"develop test plans and conduct unit, system, and integration testing"** , data does not enter the executive presentation layer unverified. A collection of programmatic PL/pgSQL assertion checks runs automatically to audit data quality gates:

```sql
-- Core Business Rule Assertion Check Sample (FTE Workload Boundary Gate)
DO $$
DECLARE 
    v_violation_count INT;
BEGIN
    SELECT COUNT(*) INTO v_violation_count 
    FROM Fact_Workforce_Snapshot 
    WHERE FTE > 1.00; -- Impossible operational overload threshold

    IF v_violation_count > 0 THEN
        RAISE EXCEPTION 'CRITICAL DATA QUALITY ERROR: % employee records exceed maximum 1.00 FTE capacity limits.', v_violation_count;
    ELSE
        RAISE NOTICE '✅ TEST PASSED: Workforce logic validation integrity clean. Zero FTE capacity overruns detected.';
    END IF;
END $$;

```

### 🔒 Operational Risk Evaluation Gates Monitored:

1. **Relational Completeness (Referential Check):** Audits the snapshot fact records to guarantee no orphaned rows exist without a valid matching dimension key.


2. **Workforce Logic Validation (Capacity Check):** Verifies that zero personnel exceed an operational capacity of $1.00\text{ FTE}$ (preventing impossible double-allocated payroll records).


3. **Data Integrity Base (Age Horizon Verification):** Validates that all dynamically grouped ages fall within legal working parameters ($18 \le \text{Age} \le 70$), securing predictive forecasting horizons from corruption.



---

## 📊 Executive Visualization Tier (Power BI Model & DAX Library)

* **Asset Location:** `reporting/EduStaff_Workforce_Model.pbix`

The data model connects to the local warehouse using a memory-optimized **Import Connection Mode** via the PostgreSQL native client provider. In strict compliance with professional modeling standards, **all database metadata schemas (`public.`) have been stripped** out , and all computational calculations are isolated away from raw table columns into a dedicated, unlinked `_Measures` folder.

### 🧮 Public-Sector Specific Calculation Library:

#### 1. Rolling 12-Month Staff Turnover Rate

Public-sector strategy cannot rely on simple calendar year-to-date values, which suffer from massive distortion during end-of-term school contract cycles. This measure smooths variations over a continuous 12-month window:


$$\text{Rolling Turnover Rate} = \frac{\text{CALCULATE(SUM(Fact[Headcount]), Fact[Status]="Terminated", DATESINPERIOD(Dim_Date[Full_Date], MAX(Dim_Date[Full_Date]), -12, MONTH))}}{\text{AVERAGEX(VALUES(Dim_Date[Calendar_Month]), CALCULATE(SUM(Fact[Headcount]), Fact[Status]="Active"))}}$$

#### 2. Dynamic Retirement Risk Matrix

To address strategic workforce stability planning targets , this calculation dynamically tracks employee longevity profiles without altering base dimensions:

```dax
Retirement Risk Tier = 
VAR EmployeeAge = [Active Employee Age]
RETURN
    SWITCH(
        TRUE(),
        EmployeeAge >= 65, "Immediate Risk (Age 65+)",
        EmployeeAge >= 60, "High Risk (Age 60-64)",
        EmployeeAge >= 55, "Medium Risk (Age 55-59)",
        "Stable Workforce (<55)"
    )

```

#### 3. Operational Utilization Metric (Headcount vs. FTE Fraction)

Provides critical insight into the operational configuration of regional school networks. It contrasts absolute body count against actual delivery capacity to flag optimization opportunities:


$$\text{FTE-to-Headcount Ratio} = \frac{\text{SUM(Fact_Workforce_Snapshot[FTE])}}{\text{CALCULATE(SUM(Fact_Workforce_Snapshot[Headcount]), Fact_Workforce_Snapshot[Status] = "Active")}}$$

> 💡 **Strategic Rule of Thumb:** A regional coefficient dropping to $0.72$ alerts regional executive hiring managers to an over-reliance on highly distributed, casual relief staff. This highlights prime regional areas for targeted, full-time local recruitment campaigns.
> 
> 

---

## 📈 Executive Dashboard Delivery Features

The interactive dashboard consists of three strategically focused evaluation panels:

1. **Strategic Workforce Profile:** Displays real-time organizational KPIs (Total active headcount vs. true budget FTE) , combined with a 5-year rolling trend chart across regional boundaries to track regional growth or stabilization patterns.


2. **Equity & Benchmarking Canvas:** Maps diversity telemetry (Indigenous representation percentage and disability inclusion indexes) explicitly against whole-of-government target benchmarks.


3. **Predictive Supply & Vacancy Forecast:** Showcases upcoming retention threat groups by pairing our **Dynamic Retirement Risk Matrix** against external university graduate supply vectors. This lets the Level 8 Workforce Planning Manager proactively discover and address upcoming vacancy gaps.