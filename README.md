# Household Income & Poverty Analysis Dashboard — Madagascar

A comprehensive data analysis project demonstrating complete workflow: data cleaning, exploratory analysis, poverty metrics computation, and interactive dashboard design. Built for a national statistics client analyzing 4,200+ households across 6 regions.

## 📊 Project Overview

This project analyzes household survey data to:
- Identify poverty patterns across regions and demographic groups
- Track seasonal income variations
- Compute poverty headcount ratios and consumption quintiles
- Deliver actionable insights through interactive dashboards

**Dataset:** 4,200 household survey records  
**Regions:** 6 administrative divisions (Madagascar)  
**Key Metrics:** Poverty headcount, income distribution, consumption patterns, seasonal indices

## 📁 Project Structure

```
household-income-poverty-dashboard/
├── README.md                           # This file
├── data/
│   ├── raw/
│   │   └── household_survey_raw.csv    # Original unprocessed data
│   ├── processed/
│   │   └── household_data_clean.csv    # Cleaned dataset
│   └── metadata/
│       └── data_dictionary.md          # Variable definitions
├── code/
│   ├── 01_data_cleaning.R              # R: Data import & cleaning
│   ├── 02_eda.R                        # R: Exploratory analysis
│   ├── 03_poverty_metrics.do           # Stata: Poverty calculations
│   ├── 04_dashboard_prep.R             # R: Dashboard data export
│   └── utils/
│       └── functions.R                 # Custom functions
├── dashboards/
│   ├── poverty_dashboard.xlsx          # Excel with VBA dashboard
│   └── power_bi/
│       └── poverty_dashboard.pbix      # Power BI interactive dashboard
├── reports/
│   ├── ministry_report.pdf             # Final client deliverable
│   └── technical_appendix.md           # Methodology details
├── docs/
│   ├── METHODOLOGY.md                  # Statistical approaches
│   ├── USAGE_GUIDE.md                  # How to run analysis
│   └── RESULTS_SUMMARY.md              # Key findings
└── .gitignore
```

## 🚀 Quick Start

### Prerequisites
- **R** (4.0+) with packages: `tidyverse`, `haven`, `survey`, `openxlsx`
- **Stata** (14+) for poverty computations
- **Excel** 2016+ (for VBA dashboard) or **Power BI Desktop**

### Run the Analysis

1. **Clone repository:**
   ```bash
   git clone https://github.com/yourusername/household-income-poverty-dashboard.git
   cd household-income-poverty-dashboard
   ```

2. **Install R dependencies:**
   ```r
   source("code/setup.R")
   ```

3. **Run analysis pipeline:**
   ```r
   source("code/01_data_cleaning.R")
   source("code/02_eda.R")
   source("code/03_poverty_metrics.do")
   source("code/04_dashboard_prep.R")
   ```

4. **View results:**
   - Open `dashboards/poverty_dashboard.xlsx` for Excel dashboard
   - Open `dashboards/power_bi/poverty_dashboard.pbix` for Power BI
   - Read `reports/ministry_report.pdf` for findings

## 📈 Key Outputs

### Dashboards
- **Regional poverty comparison:** Headcount ratios by region with trend analysis
- **Income distribution:** Consumption quintiles and Gini coefficients
- **Seasonal patterns:** Income variation by season across regions
- **Demographics:** Poverty rates by household characteristics (size, education, employment)

### Reports
- Ministry-ready report with policy recommendations
- Technical appendix with full methodology
- Executive summary with key statistics

## 🔍 Methodology

### Data Cleaning (R)
- Handle missing values and outliers
- Standardize variable names and formats
- Validate income and consumption data

### Poverty Metrics (Stata)
- **Headcount Ratio:** % of households below poverty line
- **Poverty Gap Index:** Depth of poverty
- **Consumption Quintiles:** Income distribution analysis
- **Seasonal Index:** Income variation coefficient by season

### Exploratory Analysis (R)
- Distribution analysis and hypothesis testing
- Regional comparisons and correlations
- Demographic breakdowns

### Dashboard Design (Excel/Power BI)
- Interactive filters for region, season, demographics
- KPI cards and summary statistics
- Drill-down capabilities for detailed analysis

## 📋 Data Dictionary

| Variable | Description | Type |
|----------|-------------|------|
| `hh_id` | Household identifier | Integer |
| `region` | Administrative region (6 categories) | Character |
| `monthly_income` | Monthly household income (USD) | Numeric |
| `total_consumption` | Annual consumption expenditure (USD) | Numeric |
| `hh_size` | Number of household members | Integer |
| `season` | Survey season (Dry/Wet) | Character |
| `employed_members` | Count of employed household members | Integer |
| `education_level` | Head of household education (Primary/Secondary/Tertiary) | Character |

See `data/metadata/data_dictionary.md` for complete definitions.

## 💡 Skills Demonstrated

- **Data Cleaning & Validation:** Handling survey data inconsistencies
- **Statistical Analysis:** Poverty metrics, distribution analysis, hypothesis testing
- **Programming:** R, Stata, Excel VBA
- **Dashboard Design:** Interactive visualizations, KPI tracking, drill-down analysis
- **Report Writing:** Executive summaries, technical documentation, policy insights
- **Reproducibility:** Fully documented, scriptable analysis pipeline

## 📊 Tools Used

| Tool | Purpose |
|------|---------|
| **R** | Data cleaning, EDA, visualization, report generation |
| **Stata** | Poverty metrics computation, sampling weights |
| **Excel** | VBA-based dashboard with interactive filters |
| **Power BI** | Advanced interactive dashboard and drill-through analysis |
| **RMarkdown** | Report generation and technical documentation |

## 🔐 Data Privacy

All personal identifiers have been removed. Dataset uses anonymized household IDs. Aggregated results only reveal regional and demographic patterns, not individual household data.

## 📝 License

This project is licensed under the MIT License — see LICENSE file for details.

## 👤 Author & Contact

Developed for national statistics client analysis project.  
For questions or collaborations on similar projects, contact via GitHub Issues or Upwork.

## 🎯 Use Cases

This project template is ideal for:
- Government statistics agencies analyzing survey data
- NGOs measuring poverty and development impact
- Academic research on income distribution
- Development economics consulting
- Social impact assessment

## 📚 References

- World Bank. (2020). Poverty & Equity Data.
- Foster, J., Greer, J., & Thorbecke, E. (1984). Notes on measuring poverty.
- Central Bank of Madagascar. (2021). Household Survey Methodology.

---

**Status:** ✅ Production-ready  
**Last Updated:** May 2026  
**Reproducibility:** Fully scriptable analysis with documented dependencies
