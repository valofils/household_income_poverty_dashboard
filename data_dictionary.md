# Data Dictionary

## Survey Dataset Variables

### Identifiers
| Variable | Type | Description |
|----------|------|-------------|
| `hh_id` | Integer | Unique household identifier (1-4200) |
| `region_code` | Integer | Region code (1-6) |
| `district_code` | Integer | District code within region |
| `survey_date` | Date | Date of household survey (DD/MM/YYYY) |

### Household Demographics
| Variable | Type | Description | Values |
|----------|------|-------------|--------|
| `hh_size` | Integer | Total number of household members | 1-15 |
| `hh_head_age` | Integer | Age of household head (years) | 18-95 |
| `hh_head_gender` | Character | Gender of household head | M, F |
| `hh_head_education` | Character | Education level of head | Primary, Secondary, Tertiary, None |
| `marital_status` | Character | Marital status of household head | Married, Single, Divorced, Widowed |
| `dependents` | Integer | Number of dependent children (<15 years) | 0-12 |

### Employment & Income
| Variable | Type | Description | Units |
|----------|------|-------------|-------|
| `employed_members` | Integer | Count of employed household members | Count |
| `primary_occupation` | Character | Main occupation of head | Agriculture, Trade, Services, Other |
| `monthly_income` | Numeric | Total monthly household income | USD |
| `income_source_1` | Character | Primary income source | Self-employment, Wage, Agriculture, Other |
| `income_source_2` | Character | Secondary income source (if any) | Self-employment, Wage, Agriculture, Transfers, None |
| `remittances_monthly` | Numeric | Monthly remittance income | USD |
| `agricultural_income` | Numeric | Annual agricultural income | USD |

### Consumption & Assets
| Variable | Type | Description | Units |
|----------|------|-------------|-------|
| `monthly_food_consumption` | Numeric | Monthly food expenditure | USD |
| `monthly_non_food_consumption` | Numeric | Monthly non-food expenditure (utilities, transport, health, education) | USD |
| `total_monthly_consumption` | Numeric | Total monthly consumption = food + non-food | USD |
| `owns_land` | Logical | Household owns agricultural land | TRUE/FALSE |
| `land_size_hectares` | Numeric | Size of owned agricultural land | Hectares |
| `owns_house` | Logical | Household owns dwelling | TRUE/FALSE |
| `house_quality` | Character | Housing quality assessment | Poor, Fair, Good |
| `asset_score` | Numeric | Household asset index (0-100) | Index |

### Health & Education
| Variable | Type | Description | Values |
|----------|------|-------------|--------|
| `children_in_school` | Integer | Count of school-aged children in education | Count |
| `health_expenditure_monthly` | Numeric | Monthly health expenses | USD |
| `has_health_insurance` | Logical | Household has health insurance | TRUE/FALSE |
| `illness_last_month` | Logical | Household member had illness in past month | TRUE/FALSE |

### Seasonal & Location Data
| Variable | Type | Description | Values |
|----------|------|-------------|--------|
| `season` | Character | Survey season | Dry, Wet |
| `survey_round` | Integer | Survey round (1-3, conducted quarterly) | 1, 2, 3 |
| `urban_rural` | Character | Location type | Urban, Rural |
| `region_name` | Character | Region name | Analamanga, Vakinankaratra, Itasy, Bongolava, Atsimondrano, Vatovavy-Fitovinany |

### Poverty Classification
| Variable | Type | Description | Values |
|----------|------|-------------|--------|
| `poverty_line_usd` | Numeric | Regional poverty line threshold | USD |
| `is_poor` | Logical | Household below poverty line (derived) | TRUE/FALSE |
| `consumption_quintile` | Integer | Consumption-based quintile ranking | 1 (poorest), 2, 3, 4, 5 (richest) |
| `poverty_gap` | Numeric | Poverty gap index (0 if non-poor) | 0-1 |

## Data Quality Notes

### Missing Values
- Less than 2% missing data overall
- Missing values imputed using multiple imputation by chained equations (MICE) for analysis
- Original missing patterns documented in `missing_data_report.csv`

### Outliers
- Extreme income/consumption values (>99th percentile) reviewed manually
- Agricultural income highly seasonal; seasonal indices computed separately
- Values retained if verified; documented in outlier log

### Aggregation Levels
- Individual: Household-level data (4,200 observations)
- Regional: 6 regions with 600-800 households each
- Seasonal: Data split by dry/wet season within region

### Poverty Line
- **National poverty line:** USD 1.90/person/day (World Bank PPP-adjusted)
- **Regional lines:** Adjusted for local price variations
- **Methodology:** Foster-Greer-Thorbecke (FGT) index family

## Derived Variables

### Computed During Analysis

```r
# Equivalence-adjusted household consumption
hh_data$hhc_adjusted <- hh_data$total_monthly_consumption / 
  (hh_data$hh_size ^ 0.75)

# Per capita income
hh_data$income_pc <- hh_data$monthly_income / hh_data$hh_size

# Income seasonality coefficient
# Computed as SD(income) / Mean(income) by household

# Poverty depth (PG1)
# Among poor: (poverty_line - consumption) / poverty_line

# Poverty severity (P2)
# FGT index with alpha=2
```

## Analysis-Ready Dataset

The processed dataset (`household_data_clean.csv`) includes:
- All original variables (with imputed missing values)
- All derived variables listed above
- Sampling weights (if applicable)
- Quality flags (0 = passed all checks, 1 = manual review recommended)

**Observations:** 4,200 households  
**Variables:** 45 total (25 original + 20 derived)  
**File size:** ~2.8 MB (CSV)

---

**Last Updated:** May 2026  
**Custodian:** National Statistics Agency, Madagascar
