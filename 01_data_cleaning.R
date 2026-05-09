# ============================================================================
# HOUSEHOLD INCOME & POVERTY ANALYSIS - DATA CLEANING
# Purpose: Import raw survey data, clean, validate, and export processed dataset
# ============================================================================

# Load packages
library(tidyverse)
library(haven)
library(janitor)
library(mice)
library(DataExplorer)

# Set working directory
setwd("~/household-income-poverty-dashboard")

# ============================================================================
# 1. IMPORT RAW DATA
# ============================================================================

cat("Importing raw survey data...\n")

# Read raw CSV
raw_data <- read_csv("data/raw/household_survey_raw.csv", 
                     col_types = cols(.default = "c"))

cat(sprintf("Raw data: %d rows, %d columns\n", nrow(raw_data), ncol(raw_data)))

# ============================================================================
# 2. VARIABLE STANDARDIZATION & TYPE CONVERSION
# ============================================================================

cat("\nStandardizing variables...\n")

# Standardize column names (lowercase, snake_case)
data <- raw_data %>%
  clean_names()

# Define column types
numeric_vars <- c("hh_id", "monthly_income", "total_consumption", "hh_size", 
                  "employed_members", "land_size_hectares", "asset_score",
                  "health_expenditure_monthly", "poverty_line_usd", "poverty_gap",
                  "monthly_food_consumption", "monthly_non_food_consumption",
                  "remittances_monthly", "agricultural_income")

categorical_vars <- c("region_name", "region_code", "district_code", "hh_head_gender",
                      "hh_head_education", "marital_status", "primary_occupation",
                      "income_source_1", "income_source_2", "house_quality",
                      "season", "urban_rural")

logical_vars <- c("owns_land", "owns_house", "has_health_insurance", 
                  "illness_last_month", "is_poor")

# Convert data types
data <- data %>%
  mutate(across(all_of(numeric_vars), ~as.numeric(.)),
         across(all_of(categorical_vars), ~as.factor(.)),
         across(all_of(logical_vars), ~as.logical(.)),
         survey_date = as.Date(survey_date, format = "%d/%m/%Y"),
         hh_head_age = as.integer(hh_head_age),
         dependents = as.integer(dependents),
         children_in_school = as.integer(children_in_school))

cat(sprintf("Type conversion complete. %d columns processed.\n", ncol(data)))

# ============================================================================
# 3. DATA QUALITY ASSESSMENT
# ============================================================================

cat("\nAssessing data quality...\n")

# Check for duplicates
duplicates <- data %>%
  get_dupes(hh_id)
cat(sprintf("Duplicate household IDs: %d\n", nrow(duplicates)))

# Summary of missing values
missing_summary <- data %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
  mutate(missing_pct = missing_count / nrow(data) * 100) %>%
  filter(missing_count > 0) %>%
  arrange(desc(missing_count))

cat("\nMissing Values Summary:\n")
print(missing_summary, n = Inf)

# Save missing data report
write_csv(missing_summary, "data/processed/missing_data_report.csv")

# ============================================================================
# 4. OUTLIER DETECTION
# ============================================================================

cat("\nDetecting outliers...\n")

# Function to identify outliers (>3 SD from mean)
flag_outliers <- function(x) {
  if (!is.numeric(x)) return(rep(0, length(x)))
  mean_x <- mean(x, na.rm = TRUE)
  sd_x <- sd(x, na.rm = TRUE)
  abs((x - mean_x) / sd_x) > 3
}

# Apply outlier detection to numeric variables
outlier_flags <- data %>%
  select(all_of(numeric_vars)) %>%
  mutate(across(everything(), flag_outliers)) %>%
  rowwise() %>%
  mutate(outlier_count = sum(c_across(everything()), na.rm = TRUE)) %>%
  pull(outlier_count)

data$quality_flag <- ifelse(outlier_flags > 0, 1, 0)

cat(sprintf("Records flagged for review: %d (%.2f%%)\n", 
            sum(data$quality_flag), sum(data$quality_flag) / nrow(data) * 100))

# Save outlier records for manual review
outlier_records <- data %>%
  filter(quality_flag == 1) %>%
  select(hh_id, region_name, monthly_income, total_consumption, 
         employed_members, hh_size, quality_flag)

write_csv(outlier_records, "data/processed/outlier_records.csv")

# ============================================================================
# 5. VALUE RANGE VALIDATION
# ============================================================================

cat("\nValidating value ranges...\n")

validation_issues <- list()

# Income validation: should be positive
if (any(data$monthly_income < 0, na.rm = TRUE)) {
  validation_issues$negative_income <- sum(data$monthly_income < 0, na.rm = TRUE)
}

# Consumption validation: should be positive
if (any(data$total_consumption < 0, na.rm = TRUE)) {
  validation_issues$negative_consumption <- sum(data$total_consumption < 0, na.rm = TRUE)
}

# Household size: should be 1-20
if (any(data$hh_size < 1 | data$hh_size > 20, na.rm = TRUE)) {
  validation_issues$invalid_hh_size <- sum(data$hh_size < 1 | data$hh_size > 20, na.rm = TRUE)
}

# Age validation: should be 18-100
if (any(data$hh_head_age < 18 | data$hh_head_age > 100, na.rm = TRUE)) {
  validation_issues$invalid_age <- sum(data$hh_head_age < 18 | data$hh_head_age > 100, na.rm = TRUE)
}

if (length(validation_issues) > 0) {
  cat("\nValidation Issues Found:\n")
  for (issue in names(validation_issues)) {
    cat(sprintf("  %s: %d records\n", issue, validation_issues[[issue]]))
  }
} else {
  cat("All value ranges valid.\n")
}

# ============================================================================
# 6. MISSING DATA IMPUTATION
# ============================================================================

cat("\nPerforming missing data imputation (MICE)...\n")

# Select numeric variables for imputation
vars_for_imputation <- numeric_vars[numeric_vars %in% names(data)]

# Create subset for imputation
data_for_mice <- data %>%
  select(hh_id, region_code, urban_rural, hh_size, all_of(vars_for_imputation))

# Run MICE imputation (5 iterations, 10 multiple imputations)
set.seed(42)
imputed_data <- mice(data_for_mice, m = 5, maxit = 10, method = "pmm", 
                     print = FALSE, seed = 42)

# Pool results (use first imputation for main analysis)
data_imputed <- complete(imputed_data, 1)

# Update original data with imputed values
for (var in vars_for_imputation) {
  data[[var]] <- data_imputed[[var]]
}

cat("Imputation complete.\n")

# ============================================================================
# 7. DERIVED VARIABLES
# ============================================================================

cat("\nComputing derived variables...\n")

data <- data %>%
  mutate(
    # Per capita indicators
    income_pc = monthly_income / hh_size,
    consumption_pc = total_consumption / hh_size,
    
    # Equivalence-adjusted consumption (household size elasticity = 0.75)
    hhc_adjusted = total_consumption / (hh_size ^ 0.75),
    
    # Employed ratio
    employment_ratio = employed_members / hh_size,
    
    # Asset poverty (below median asset score)
    asset_poor = asset_score < median(asset_score, na.rm = TRUE),
    
    # Vulnerability indicator
    vulnerable = (employment_ratio < 0.5) & (asset_score < 50),
    
    # Consumption composition
    food_share = monthly_food_consumption / total_monthly_consumption,
    
    # Log income (for regression analysis)
    log_income = log(monthly_income + 1),
    log_consumption = log(total_monthly_consumption + 1)
  )

cat(sprintf("Derived variables: 11 new variables created.\n"))

# ============================================================================
# 8. CATEGORICAL STANDARDIZATION
# ============================================================================

cat("\nStandardizing categorical variables...\n")

# Education levels
data$hh_head_education <- factor(data$hh_head_education, 
                                 levels = c("None", "Primary", "Secondary", "Tertiary"),
                                 ordered = TRUE)

# House quality
data$house_quality <- factor(data$house_quality,
                             levels = c("Poor", "Fair", "Good"),
                             ordered = TRUE)

# Marital status
data$marital_status <- factor(data$marital_status,
                              levels = c("Single", "Married", "Divorced", "Widowed"))

# Occupation
data$primary_occupation <- factor(data$primary_occupation,
                                  levels = c("Agriculture", "Trade", "Services", "Other"))

cat("Categorical variables standardized.\n")

# ============================================================================
# 9. FINAL VALIDATION & SUMMARY STATISTICS
# ============================================================================

cat("\nFinal dataset summary:\n")
cat(sprintf("  Observations: %d\n", nrow(data)))
cat(sprintf("  Variables: %d\n", ncol(data)))
cat(sprintf("  Regions: %d\n", n_distinct(data$region_name)))
cat(sprintf("  Date range: %s to %s\n", 
            min(data$survey_date, na.rm = TRUE), 
            max(data$survey_date, na.rm = TRUE)))

# Summary statistics by region
summary_by_region <- data %>%
  group_by(region_name) %>%
  summarise(
    n = n(),
    mean_income = mean(monthly_income, na.rm = TRUE),
    mean_consumption = mean(total_monthly_consumption, na.rm = TRUE),
    mean_hh_size = mean(hh_size, na.rm = TRUE),
    poor_pct = mean(is_poor, na.rm = TRUE) * 100,
    .groups = "drop"
  )

cat("\nSummary by Region:\n")
print(summary_by_region)

write_csv(summary_by_region, "data/processed/summary_by_region.csv")

# ============================================================================
# 10. EXPORT CLEANED DATA
# ============================================================================

cat("\nExporting cleaned data...\n")

# Select and order final variables
final_data <- data %>%
  select(hh_id, region_code, region_name, district_code, survey_date, season,
         urban_rural, hh_size, hh_head_age, hh_head_gender, hh_head_education,
         marital_status, dependents, employed_members, primary_occupation,
         income_source_1, income_source_2, monthly_income, agricultural_income,
         remittances_monthly, income_pc, log_income, owns_land, land_size_hectares,
         owns_house, house_quality, asset_score, monthly_food_consumption,
         monthly_non_food_consumption, total_monthly_consumption, 
         consumption_pc, hhc_adjusted, log_consumption, food_share,
         children_in_school, health_expenditure_monthly, has_health_insurance,
         illness_last_month, poverty_line_usd, is_poor, consumption_quintile,
         poverty_gap, employment_ratio, asset_poor, vulnerable, quality_flag)

# Export as CSV
write_csv(final_data, "data/processed/household_data_clean.csv")

# Export as R data object
save(final_data, file = "data/processed/household_data_clean.RData")

cat(sprintf("✓ Cleaned data saved: %d rows, %d columns\n", 
            nrow(final_data), ncol(final_data)))

# ============================================================================
# 11. DATA CLEANING REPORT
# ============================================================================

cat("\nGenerating data cleaning report...\n")

cleaning_report <- data.frame(
  Stage = c("Original data", "After type conversion", "After validation",
            "After imputation", "After derived variables", "Final dataset"),
  Records = c(nrow(raw_data), nrow(data), nrow(data), nrow(data), nrow(data), nrow(final_data)),
  Variables = c(ncol(raw_data), ncol(data), ncol(data), ncol(data), ncol(data) + 11, ncol(final_data)),
  Issues = c(0, nrow(missing_summary), nrow(outlier_records), 0, 0, 0)
)

write_csv(cleaning_report, "data/processed/cleaning_report.csv")

cat("\n")
cat("=" %+% strrep("=", 75) %+% "\n")
cat("DATA CLEANING COMPLETE\n")
cat("=" %+% strrep("=", 75) %+% "\n")
cat(sprintf("Output files saved to: data/processed/\n"))
cat(sprintf("Ready for analysis: code/02_eda.R\n"))
cat("=" %+% strrep("=", 75) %+% "\n")
