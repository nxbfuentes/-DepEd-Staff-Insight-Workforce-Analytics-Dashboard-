import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Set random seed for reproducibility
np.random.seed(42)

# 1. Define Parameters & WA Education Context
num_employees = 5000

roles = ['Teacher', 'Lead Teacher', 'Principal', 'Deputy Principal', 'Education Assistant', 'Aboriginal Education Officer', 'School Administrator']
role_weights = [0.55, 0.10, 0.03, 0.05, 0.15, 0.04, 0.08]

wa_regions = ['North Metro', 'South Metro', 'Goldfields', 'Kimberley', 'Pilbara', 'Mid West', 'Wheatbelt', 'South West', 'Great Southern']
region_weights = [0.35, 0.30, 0.04, 0.04, 0.04, 0.05, 0.06, 0.08, 0.04]

genders = ['Female', 'Male', 'Non-binary']
gender_weights = [0.72, 0.27, 0.01] # Teaching workforce historically skews female

# 2. Generate Base Demographic Data
emp_ids = [f"ED{100000 + i}" for i in range(num_employees)]
chosen_roles = np.random.choice(roles, size=num_employees, p=role_weights)
chosen_regions = np.random.choice(wa_regions, size=num_employees, p=region_weights)
chosen_genders = np.random.choice(genders, size=num_employees, p=gender_weights)

# Generate Ages skewed slightly older to simulate "Retirement Risk" criteria
ages = np.random.normal(loc=44, scale=12, size=num_employees).astype(int)
ages = np.clip(ages, 21, 67) # Keep ages within realistic working limits

# Diversity Indicators (Targeting Selection Criteria & Equity Benchmarks)
indigenous_status = np.random.choice(['Yes', 'No'], size=num_employees, p=[0.05, 0.95])
disability_status = np.random.choice(['Yes', 'No'], size=num_employees, p=[0.04, 0.96])

# 3. Generate Employment Dates & Status
employment_types = np.random.choice(['Permanent Full-Time', 'Permanent Part-Time', 'Fixed Term', 'Casual'], size=num_employees, p=[0.60, 0.20, 0.15, 0.05])

start_dates = []
exit_dates = []
current_status = []

base_date = datetime(2026, 5, 22) # Present Day Context

for age in ages:
    # Calculate a realistic maximum tenure based on age
    max_tenure_years = min(age - 21, 35)
    if max_tenure_years <= 0:
        tenure_days = np.random.randint(30, 365)
    else:
        tenure_days = np.random.randint(30, max_tenure_years * 365)
        
    start_date = base_date - timedelta(days=int(tenure_days))
    start_dates.append(start_date)
    
    # Simulate historical attrition (Turnover tracking)
    # Higher exit probability for older employees (retirement) or random attrition
    is_retired = age >= 60 and np.random.rand() < 0.35
    is_resigned = np.random.rand() < 0.15 # 15% historical turnover rate
    
    if (is_retired or is_resigned) and start_date < base_date - timedelta(days=365):
        # Left somewhere between hiring date and today
        days_to_exit = np.random.randint(180, int((base_date - start_date).days))
        exit_date = start_date + timedelta(days=days_to_exit)
        exit_dates.append(exit_date.strftime('%Y-%m-%d'))
        current_status.append('Terminated')
    else:
        exit_dates.append(None)
        current_status.append('Active')

# 4. Create DataFrame
df = pd.DataFrame({
    'EmployeeID': emp_ids,
    'Gender': chosen_genders,
    'Age': ages,
    'IndigenousIdentity': indigenous_status,
    'DisabilityStatus': disability_status,
    'Role': chosen_roles,
    'WARegion': chosen_regions,
    'EmploymentType': employment_types,
    'Status': current_status,
    'CommencementDate': [d.strftime('%Y-%m-%d') for d in start_dates],
    'SeparationDate': exit_dates
})

# Calculate FTE (Full Time Equivalent) based on employment type
df['FTE'] = df['EmploymentType'].map({
    'Permanent Full-Time': 1.0,
    'Permanent Part-Time': 0.6,
    'Fixed Term': 1.0,
    'Casual': 0.2
})

# Save to CSV for database staging / Power BI loading
df.to_csv('raw_workforce_data.csv', index=False)
print(f"Successfully generated {num_employees} mock HR records in 'raw_workforce_data.csv'!")
