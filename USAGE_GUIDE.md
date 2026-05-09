# USAGE GUIDE: Running the Household Income & Poverty Analysis

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Installation](#installation)
3. [Data Preparation](#data-preparation)
4. [Running the Analysis](#running-the-analysis)
5. [Viewing Results](#viewing-results)
6. [Troubleshooting](#troubleshooting)
7. [Customization](#customization)

---

## System Requirements

### Software Requirements

**R (Required)**
- Version: 4.0 or higher
- Download: https://cloud.r-project.org/

**RStudio (Recommended)**
- Version: Latest stable release
- Download: https://posit.co/download/rstudio-desktop/

**Stata (Optional)**
- Version: 14.0 or higher
- For official poverty indices computation
- If unavailable: R implementation provided as alternative

**Excel/Power BI (Optional)**
- Excel 2016+ for VBA dashboard (recommended for Windows)
- Power BI Desktop for interactive dashboard
- Download: https://www.microsoft.com/power-bi/

### Hardware Requirements
- Minimum: 4 GB RAM, 500 MB free disk space
- Recommended: 8 GB RAM, 1 GB free disk space

### Operating System
- Windows 7+, macOS 10.13+, or Linux (Ubuntu 18.04+)

---

## Installation

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/household-income-poverty-dashboard.git
cd household-income-poverty-dashboard
```

Or download as ZIP:
- Go to GitHub repository
- Click "Code" → "Download ZIP"
- Extract folder to desired location

### Step 2: Install R Packages

Open R or RStudio and run:

```r
# Install required packages
packages_needed <- c(
  "tidyverse",      # Data manipulation
  "ggplot2",        # Visualization
  "haven",          # Read Stata/SPSS files
  "janitor",        # Data cleaning
  "mice",           # Missing data imputation
  "corrplot",       # Correlation plots
  "openxlsx",       # Excel export
  "scales",         # Number formatting
  "gridExtra"       # Multi-panel plots
)

for (pkg in packages_needed) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
  }
}

cat("All packages installed successfully!\n")
```

**Expected installation time:** 2-5 minutes depending on internet speed

### Step 3: Verify Installation

Test that packages load correctly:

```r
source("code/setup.R")
```

Output should show:
```
✓ tidyverse loaded
✓ ggplot2 loaded
✓ haven loaded
✓ janitor loaded
✓ mice loaded
✓ corrplot loaded
✓ openxlsx loaded
✓ All packages verified
```

---

## Data Preparation

### Input Data Format

**Raw data file location:** `data/raw/household_survey_raw.csv`

**Required columns (case-insensitive):**
```
hh_id, region_name, monthly_income, total_consumption, hh_size,
hh_head_age, hh_head_gender, hh_head_education, marital_status,
dependents, employed_members, primary_occupation, income_source_1,
income_source_2, owns_land, land_size_hectares, owns_house,
house_quality, asset_score, season, survey_date, poverty_line_usd,
is_poor, consumption_quintile, poverty_gap
```

**Data types:**
- Numeric columns: Double/Float (e.g., monthly_income)
- Character columns: String (e.g., region_name)
- Date columns: YYYY-MM-DD format (e.g., 2023-01-15)
- Logical: TRUE/FALSE for is_poor

### Sample Data Structure

```csv
hh_id,region_name,monthly_income,total_consumption,hh_size,season
1001,Analamanga,250.50,220.75,4,Dry
1002,Analamanga,180.25,175.50,5,Dry
1003,Vakinankaratra,300.00,290.25,3,Wet
```

### Data Validation Checklist

Before running analysis, verify:
- [ ] No duplicate hh_id values
- [ ] All numeric columns contain only numbers
- [ ] Date format is consistent (YYYY-MM-DD)
- [ ] No leading/trailing spaces in text columns
- [ ] Poverty line is positive and reasonable (1.50-2.50 USD range)
- [ ] Income and consumption > 0
- [ ] Household size 1-20
- [ ] Missing values represented as NA (not blank or "NULL")

---

## Running the Analysis

### Option 1: Run Full Pipeline (Recommended)

Execute all steps sequentially with automatic error checking:

```r
# Set working directory
setwd("~/household-income-poverty-dashboard")

# Run entire pipeline
source("code/00_run_all.R")
```

**Expected duration:** 15-25 minutes

**Output messages should include:**
```
✓ Data cleaning complete
✓ EDA complete
✓ Dashboard preparation complete
Ready for visualization!
```

### Option 2: Run Individual Steps

Run each analysis step separately to examine intermediate results:

#### Step 1: Data Cleaning
```r
setwd("~/household-income-poverty-dashboard")
source("code/01_data_cleaning.R")
```

**Outputs:**
- `data/processed/household_data_clean.csv` (cleaned dataset)
- `data/processed/missing_data_report.csv` (imputation details)
- `data/processed/outlier_records.csv` (quality flagged records)
- Console: Data quality summary and regional statistics

**Check:** No error messages, ≥4000 records processed

#### Step 2: Exploratory Data Analysis
```r
source("code/02_eda.R")
```

**Outputs:**
- `reports/figures/` (11 PNG visualization files)
- `data/processed/regional_summary.csv`
- `data/processed/quintile_analysis.csv`
- `data/processed/seasonal_analysis.csv`
- Console: Descriptive statistics

**Check:** All visualization files created, statistics displayed

#### Step 3: Poverty Metrics (Stata)

```stata
do code/03_poverty_metrics.do
```

Or use R alternative (if Stata unavailable):
```r
source("code/03_poverty_metrics_alternative.R")
```

**Outputs:**
- `data/processed/poverty_indices.csv` (FGT indices)
- `reports/poverty_estimates_by_region.txt`

#### Step 4: Dashboard Preparation
```r
source("code/04_dashboard_prep.R")
```

**Outputs:**
- `dashboards/data/dashboard_summary.xlsx`
- `dashboards/data/regional_breakdown.csv`
- `dashboards/data/quintile_data.csv`

---

## Viewing Results

### Excel Dashboard

1. **Open file:** `dashboards/poverty_dashboard.xlsx`
2. **Enable macros** when prompted (required for interactivity)
3. **Navigate sheets:**
   - "Dashboard" = Main KPIs and charts
   - "Regional Analysis" = Regional breakdowns
   - "Demographic" = Education and household composition

**Using interactive elements:**
- Click slicer buttons to filter by region or season
- Right-click pivot tables to change data display
- Refresh data: Data tab → Refresh All

### Power BI Dashboard

1. **Install:** Power BI Desktop (free from Microsoft)
2. **Open file:** `dashboards/power_bi/poverty_dashboard.pbix`
3. **Report pages:**
   - Overview: National summary KPIs
   - Regional: Map and regional comparisons
   - Demographics: Breakdowns by education/employment
   - Seasonality: Income and poverty variation
   - Quintiles: Income distribution analysis

**Using interactive features:**
- Click chart elements to cross-filter other visuals
- Use slicer pane (left) to filter by region/season
- Hover over data points for tooltips
- Click drill-through buttons for detailed views

### Reports & Documentation

**View key findings:**
- `reports/ministry_report.pdf` - Executive summary and policy recommendations
- `reports/RESULTS_SUMMARY.md` - Key statistics and tables
- `reports/EDA_SUMMARY.txt` - Exploratory analysis output
- `docs/METHODOLOGY.md` - Statistical methodology

---

## Troubleshooting

### Issue: Package Installation Fails

**Error:** `package 'tidyverse' is not available`

**Solution:**
```r
# Update R packages
update.packages()

# Try manual installation with verbose output
install.packages("tidyverse", verbose = TRUE, dependencies = TRUE)
```

### Issue: Data File Not Found

**Error:** `Error in read_csv("data/raw/household_survey_raw.csv")`

**Solution:**
1. Verify working directory:
```r
getwd()
# Should output: /Users/yourname/household-income-poverty-dashboard
```
2. Check file exists:
```r
file.exists("data/raw/household_survey_raw.csv")
# Should return TRUE
```
3. If missing, place raw data file at correct location

### Issue: Out of Memory During Imputation

**Error:** `Error: cannot allocate vector of size X GB`

**Solution:**
- Reduce imputation iterations:
```r
# In code/01_data_cleaning.R, change line:
imputed_data <- mice(data_for_mice, m = 3, maxit = 5, ...)  # Reduced from m=5, maxit=10
```
- Close other applications
- Use 64-bit R version

### Issue: Stata File Not Found

**Error:** `file 03_poverty_metrics.do not found`

**Solution:**
- Use R alternative:
```r
source("code/03_poverty_metrics_alternative.R")
```
- Or install Stata if required for official indices

### Issue: Excel Macros Not Working

**Error:** "Compile error in hidden module" or disabled macros

**Solution:**
1. Enable macros:
   - File → Options → Trust Center → Macro Settings
   - Select "Enable all macros"
2. Verify VBA references:
   - Press Alt+F11 in Excel
   - Tools → References
   - Ensure "Visual Basic For Applications" is checked

### Issue: Power BI Won't Load Data

**Error:** "Power Query error" or blank dashboard

**Solution:**
1. Refresh data:
   - Home → Refresh
2. Check data source path:
   - Transform data → Data source settings
   - Update path if files moved
3. Reinstall Power BI (if persistent)

---

## Customization

### Changing the Poverty Line

Edit in `code/01_data_cleaning.R`:

```r
# Original (line ~45):
POVERTY_LINE <- 1.90  # USD per person per day

# Update to custom value:
POVERTY_LINE <- 2.50  # USD per person per day
```

Run cleaning and analysis again.

### Adding New Regions

If survey includes additional regions:

1. Update data dictionary: `data/metadata/data_dictionary.md`
2. Ensure region codes are sequential in raw data
3. Run analysis; visualizations auto-generate for all regions

### Modifying Visualization Styles

Edit color schemes in `code/02_eda.R`:

```r
# Original color palette:
scale_fill_manual(values = c("Poor" = "#D62828", "Non-Poor" = "#06A77D"))

# Custom colors (use hex codes):
scale_fill_manual(values = c("Poor" = "#CC0000", "Non-Poor" = "#009900"))
```

### Creating Additional Analysis

Add new R scripts in `code/` following naming convention:
```
05_additional_analysis.R
06_vulnerability_index.R
```

---

## Advanced Options

### Batch Processing (No RStudio)

Run from command line:
```bash
Rscript code/00_run_all.R
```

### Parallel Processing

For large datasets, enable parallel processing:

```r
library(parallel)

# Before MICE imputation:
cl <- makeCluster(detectCores() - 1)
clusterExport(cl, "data_for_mice", envir = environment())

# Modify MICE call:
imputed_data <- mice(data_for_mice, m = 5, maxit = 10, 
                     parallel = TRUE, seed = 42)
```

### Database Integration

Export to database instead of CSV:

```r
library(DBI)

# Connect to database
con <- dbConnect(RSQLite::SQLite(), "poverty_analysis.db")

# Write results
dbWriteTable(con, "households", final_data, overwrite = TRUE)
dbWriteTable(con, "regional_summary", regional_summary, overwrite = TRUE)

dbDisconnect(con)
```

---

## Getting Help

- **Code errors:** Check console output, verify data types
- **Methodology questions:** See `docs/METHODOLOGY.md`
- **Data issues:** Review `data/processed/missing_data_report.csv`
- **GitHub issues:** Submit via repository Issues tab
- **Email support:** Contact analysis team

---

**Last Updated:** May 2026  
**Version:** 1.0
