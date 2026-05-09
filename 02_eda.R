# ============================================================================
# HOUSEHOLD INCOME & POVERTY ANALYSIS - EXPLORATORY DATA ANALYSIS
# Purpose: Analyze distributions, correlations, and regional patterns
# ============================================================================

library(tidyverse)
library(ggplot2)
library(scales)
library(gridExtra)
library(corrplot)

setwd("~/household-income-poverty-dashboard")

# Load cleaned data
load("data/processed/household_data_clean.RData")

cat("Loaded cleaned dataset: ", nrow(final_data), " households\n")

# ============================================================================
# 1. UNIVARIATE ANALYSIS
# ============================================================================

cat("\n" %+% strrep("=", 75) %+% "\n")
cat("1. UNIVARIATE ANALYSIS\n")
cat(strrep("=", 75) %+% "\n")

# Income distribution
income_stats <- final_data %>%
  summarise(
    Mean = mean(monthly_income, na.rm = TRUE),
    Median = median(monthly_income, na.rm = TRUE),
    SD = sd(monthly_income, na.rm = TRUE),
    Min = min(monthly_income, na.rm = TRUE),
    Max = max(monthly_income, na.rm = TRUE),
    Q1 = quantile(monthly_income, 0.25, na.rm = TRUE),
    Q3 = quantile(monthly_income, 0.75, na.rm = TRUE)
  ) %>%
  round(2)

cat("\nMonthly Income Statistics (USD):\n")
print(income_stats)

# Consumption distribution
consumption_stats <- final_data %>%
  summarise(
    Mean = mean(total_monthly_consumption, na.rm = TRUE),
    Median = median(total_monthly_consumption, na.rm = TRUE),
    SD = sd(total_monthly_consumption, na.rm = TRUE),
    Min = min(total_monthly_consumption, na.rm = TRUE),
    Max = max(total_monthly_consumption, na.rm = TRUE),
    Q1 = quantile(total_monthly_consumption, 0.25, na.rm = TRUE),
    Q3 = quantile(total_monthly_consumption, 0.75, na.rm = TRUE)
  ) %>%
  round(2)

cat("\nTotal Monthly Consumption Statistics (USD):\n")
print(consumption_stats)

# Poverty statistics
poverty_stats <- final_data %>%
  summarise(
    Total_HH = n(),
    Poor_HH = sum(is_poor, na.rm = TRUE),
    Poverty_Headcount = mean(is_poor, na.rm = TRUE) * 100,
    Vulnerable_HH = sum(vulnerable, na.rm = TRUE),
    Vulnerable_Pct = mean(vulnerable, na.rm = TRUE) * 100,
    Asset_Poor = sum(asset_poor, na.rm = TRUE),
    Asset_Poor_Pct = mean(asset_poor, na.rm = TRUE) * 100
  ) %>%
  round(2)

cat("\nPoverty Indicators:\n")
print(poverty_stats)

# Household demographics
hh_stats <- final_data %>%
  summarise(
    Mean_HH_Size = mean(hh_size, na.rm = TRUE),
    Mean_Head_Age = mean(hh_head_age, na.rm = TRUE),
    Mean_Dependents = mean(dependents, na.rm = TRUE),
    Mean_Employed = mean(employed_members, na.rm = TRUE),
    Mean_Education_Yrs = mean(case_when(
      hh_head_education == "None" ~ 0,
      hh_head_education == "Primary" ~ 6,
      hh_head_education == "Secondary" ~ 12,
      hh_head_education == "Tertiary" ~ 16
    ), na.rm = TRUE)
  ) %>%
  round(2)

cat("\nHousehold Demographics:\n")
print(hh_stats)

# ============================================================================
# 2. DISTRIBUTIONS - VISUALIZATIONS
# ============================================================================

cat("\nGenerating distribution plots...\n")

# Income distribution plot
p1 <- ggplot(final_data, aes(x = monthly_income)) +
  geom_histogram(bins = 50, fill = "#2E86AB", alpha = 0.8) +
  scale_x_continuous(labels = dollar) +
  labs(title = "Monthly Household Income Distribution",
       x = "Monthly Income (USD)", y = "Frequency",
       subtitle = sprintf("Mean: %s, Median: %s", 
                          dollar(mean(final_data$monthly_income, na.rm = TRUE)),
                          dollar(median(final_data$monthly_income, na.rm = TRUE)))) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 12))

# Log income distribution
p2 <- ggplot(final_data, aes(x = log_income)) +
  geom_histogram(bins = 50, fill = "#A23B72", alpha = 0.8) +
  labs(title = "Log-Transformed Income Distribution",
       x = "Log Monthly Income", y = "Frequency") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 12))

# Consumption distribution
p3 <- ggplot(final_data, aes(x = total_monthly_consumption)) +
  geom_histogram(bins = 50, fill = "#F18F01", alpha = 0.8) +
  scale_x_continuous(labels = dollar) +
  labs(title = "Monthly Consumption Distribution",
       x = "Monthly Consumption (USD)", y = "Frequency") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 12))

# Poverty indicator
p4 <- final_data %>%
  mutate(poverty_status = ifelse(is_poor, "Poor", "Non-Poor")) %>%
  ggplot(aes(x = poverty_status, fill = poverty_status)) +
  geom_bar() +
  scale_fill_manual(values = c("Poor" = "#D62828", "Non-Poor" = "#06A77D")) +
  geom_text(stat = "count", aes(label = sprintf("%.1f%%", 
            ..count.. / sum(..count..) * 100)), vjust = -0.5) +
  labs(title = "Poverty Headcount", x = "", y = "Number of Households") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold", size = 12))

ggsave("reports/figures/01_income_distribution.png", p1, width = 10, height = 6, dpi = 300)
ggsave("reports/figures/02_log_income_distribution.png", p2, width = 10, height = 6, dpi = 300)
ggsave("reports/figures/03_consumption_distribution.png", p3, width = 10, height = 6, dpi = 300)
ggsave("reports/figures/04_poverty_status.png", p4, width = 8, height = 6, dpi = 300)

cat("✓ Distribution plots saved\n")

# ============================================================================
# 3. REGIONAL ANALYSIS
# ============================================================================

cat("\nAnalyzing regional patterns...\n")

regional_summary <- final_data %>%
  group_by(region_name) %>%
  summarise(
    N_Households = n(),
    Mean_Income = mean(monthly_income, na.rm = TRUE),
    Median_Income = median(monthly_income, na.rm = TRUE),
    SD_Income = sd(monthly_income, na.rm = TRUE),
    Mean_Consumption = mean(total_monthly_consumption, na.rm = TRUE),
    Poverty_Rate = mean(is_poor, na.rm = TRUE) * 100,
    Mean_HH_Size = mean(hh_size, na.rm = TRUE),
    Mean_Asset_Score = mean(asset_score, na.rm = TRUE),
    Urban_Pct = mean(urban_rural == "Urban") * 100,
    .groups = "drop"
  ) %>%
  arrange(Poverty_Rate)

cat("\nRegional Summary Statistics:\n")
print(regional_summary)
write_csv(regional_summary, "data/processed/regional_summary.csv")

# Regional poverty comparison
p5 <- ggplot(regional_summary, aes(x = reorder(region_name, -Poverty_Rate), 
                                    y = Poverty_Rate, fill = Poverty_Rate)) +
  geom_col() +
  geom_text(aes(label = sprintf("%.1f%%", Poverty_Rate)), vjust = -0.5) +
  scale_fill_gradient(low = "#06A77D", high = "#D62828") +
  labs(title = "Poverty Headcount Ratio by Region",
       x = "Region", y = "Poverty Rate (%)",
       subtitle = "Higher headcount indicates more households below poverty line") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none",
        plot.title = element_text(face = "bold", size = 12))

# Regional income comparison
p6 <- ggplot(regional_summary, aes(x = reorder(region_name, -Mean_Income), 
                                    y = Mean_Income, fill = Mean_Income)) +
  geom_col() +
  scale_y_continuous(labels = dollar) +
  scale_fill_gradient(low = "#D62828", high = "#06A77D") +
  labs(title = "Average Monthly Income by Region",
       x = "Region", y = "Mean Income (USD)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none",
        plot.title = element_text(face = "bold", size = 12))

ggsave("reports/figures/05_poverty_by_region.png", p5, width = 10, height = 6, dpi = 300)
ggsave("reports/figures/06_income_by_region.png", p6, width = 10, height = 6, dpi = 300)

cat("✓ Regional analysis complete\n")

# ============================================================================
# 4. CONSUMPTION QUINTILE ANALYSIS
# ============================================================================

cat("\nAnalyzing consumption quintiles...\n")

quintile_analysis <- final_data %>%
  group_by(consumption_quintile) %>%
  summarise(
    N = n(),
    Mean_Income = mean(monthly_income, na.rm = TRUE),
    Mean_Consumption = mean(total_monthly_consumption, na.rm = TRUE),
    Mean_HH_Size = mean(hh_size, na.rm = TRUE),
    Poverty_Rate = mean(is_poor, na.rm = TRUE) * 100,
    Pct_Poor = mean(is_poor, na.rm = TRUE) * 100,
    Mean_Education = mean(case_when(
      hh_head_education == "None" ~ 0,
      hh_head_education == "Primary" ~ 1,
      hh_head_education == "Secondary" ~ 2,
      hh_head_education == "Tertiary" ~ 3
    ), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(Quintile_Label = c("Q1: Poorest", "Q2", "Q3: Middle", "Q4", "Q5: Richest"))

cat("\nConsumption Quintile Analysis:\n")
print(quintile_analysis)
write_csv(quintile_analysis, "data/processed/quintile_analysis.csv")

# Quintile visualization
p7 <- ggplot(quintile_analysis, aes(x = Quintile_Label, y = Mean_Consumption, fill = Quintile_Label)) +
  geom_col() +
  scale_y_continuous(labels = dollar) +
  scale_fill_brewer(palette = "RdYlGn") +
  geom_text(aes(label = dollar(Mean_Consumption)), vjust = -0.5) +
  labs(title = "Average Consumption by Quintile",
       x = "Consumption Quintile", y = "Mean Monthly Consumption (USD)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold", size = 12))

ggsave("reports/figures/07_consumption_quintiles.png", p7, width = 10, height = 6, dpi = 300)

cat("✓ Quintile analysis complete\n")

# ============================================================================
# 5. SEASONAL ANALYSIS
# ============================================================================

cat("\nAnalyzing seasonal patterns...\n")

seasonal_analysis <- final_data %>%
  group_by(season) %>%
  summarise(
    N = n(),
    Mean_Income = mean(monthly_income, na.rm = TRUE),
    SD_Income = sd(monthly_income, na.rm = TRUE),
    Mean_Consumption = mean(total_monthly_consumption, na.rm = TRUE),
    SD_Consumption = sd(total_monthly_consumption, na.rm = TRUE),
    Poverty_Rate = mean(is_poor, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  mutate(CV_Income = SD_Income / Mean_Income * 100,
         CV_Consumption = SD_Consumption / Mean_Consumption * 100)

cat("\nSeasonal Analysis:\n")
print(seasonal_analysis)
write_csv(seasonal_analysis, "data/processed/seasonal_analysis.csv")

# Seasonal poverty variation by region
p8 <- final_data %>%
  group_by(region_name, season) %>%
  summarise(Poverty_Rate = mean(is_poor, na.rm = TRUE) * 100, .groups = "drop") %>%
  ggplot(aes(x = region_name, y = Poverty_Rate, fill = season)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = sprintf("%.1f%%", Poverty_Rate)), 
            position = position_dodge(width = 0.9), vjust = -0.3, size = 3) +
  scale_fill_manual(values = c("Dry" = "#E8B4B8", "Wet" = "#4A90E2")) +
  labs(title = "Poverty Rates by Region and Season",
       x = "Region", y = "Poverty Rate (%)", fill = "Season") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(face = "bold", size = 12))

ggsave("reports/figures/08_seasonal_poverty.png", p8, width = 10, height = 6, dpi = 300)

cat("✓ Seasonal analysis complete\n")

# ============================================================================
# 6. CORRELATION ANALYSIS
# ============================================================================

cat("\nAnalyzing correlations...\n")

# Select numeric variables for correlation
corr_vars <- c("monthly_income", "total_monthly_consumption", "hh_size",
               "hh_head_age", "employed_members", "asset_score", "poverty_gap")

correlation_matrix <- final_data %>%
  select(all_of(corr_vars)) %>%
  cor(use = "complete.obs")

# Correlation plot
png("reports/figures/09_correlation_matrix.png", width = 800, height = 800)
corrplot(correlation_matrix, method = "color", type = "upper",
         tl.col = "black", tl.srt = 45, addCoef.col = "black",
         main = "Correlation Matrix: Income, Consumption, and Demographic Variables")
dev.off()

cat("✓ Correlation analysis complete\n")

# ============================================================================
# 7. DEMOGRAPHIC ANALYSIS
# ============================================================================

cat("\nAnalyzing demographic patterns...\n")

# Poverty by education
education_analysis <- final_data %>%
  group_by(hh_head_education) %>%
  summarise(
    N = n(),
    Poverty_Rate = mean(is_poor, na.rm = TRUE) * 100,
    Mean_Income = mean(monthly_income, na.rm = TRUE),
    Mean_Consumption = mean(total_monthly_consumption, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nPoverty by Education Level:\n")
print(education_analysis)

p9 <- ggplot(education_analysis, aes(x = hh_head_education, y = Poverty_Rate, fill = Poverty_Rate)) +
  geom_col() +
  geom_text(aes(label = sprintf("%.1f%%", Poverty_Rate)), vjust = -0.5) +
  scale_fill_gradient(low = "#06A77D", high = "#D62828") +
  labs(title = "Poverty Rate by Head of Household Education Level",
       x = "Education Level", y = "Poverty Rate (%)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold", size = 12))

ggsave("reports/figures/10_poverty_by_education.png", p9, width = 10, height = 6, dpi = 300)

# Urban vs Rural
urban_rural_analysis <- final_data %>%
  group_by(urban_rural) %>%
  summarise(
    N = n(),
    Poverty_Rate = mean(is_poor, na.rm = TRUE) * 100,
    Mean_Income = mean(monthly_income, na.rm = TRUE),
    Mean_Consumption = mean(total_monthly_consumption, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nUrban vs Rural Analysis:\n")
print(urban_rural_analysis)
write_csv(urban_rural_analysis, "data/processed/urban_rural_analysis.csv")

p10 <- ggplot(urban_rural_analysis, aes(x = urban_rural, y = Poverty_Rate, fill = urban_rural)) +
  geom_col() +
  geom_text(aes(label = sprintf("%.1f%%", Poverty_Rate)), vjust = -0.5) +
  scale_fill_manual(values = c("Urban" = "#2E86AB", "Rural" = "#A23B72")) +
  labs(title = "Poverty Rate: Urban vs Rural",
       x = "Location Type", y = "Poverty Rate (%)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold", size = 12))

ggsave("reports/figures/11_poverty_urban_rural.png", p10, width = 8, height = 6, dpi = 300)

cat("✓ Demographic analysis complete\n")

# ============================================================================
# 8. SUMMARY REPORT
# ============================================================================

cat("\n" %+% strrep("=", 75) %+% "\n")
cat("EDA COMPLETE - SUMMARY\n")
cat(strrep("=", 75) %+% "\n")

summary_output <- sprintf(
  "
Key Findings:
  • Total Households: %d
  • National Poverty Rate: %.2f%%
  • Average Monthly Income: %s
  • Average Monthly Consumption: %s
  • Mean Household Size: %.2f members
  • Regions Analyzed: %d
  
Outputs Generated:
  • 11 visualization PNG files (reports/figures/)
  • 5 summary statistics CSV files (data/processed/)
  • Correlation matrix and demographic breakdowns
  
Next Steps:
  • Run 03_poverty_metrics.do (Stata) for official poverty indices
  • Run 04_dashboard_prep.R for dashboard data export
  • See reports/METHODOLOGY.md for detailed methodology
  
",
  nrow(final_data),
  mean(final_data$is_poor, na.rm = TRUE) * 100,
  dollar(mean(final_data$monthly_income, na.rm = TRUE)),
  dollar(mean(final_data$total_monthly_consumption, na.rm = TRUE)),
  mean(final_data$hh_size, na.rm = TRUE),
  n_distinct(final_data$region_name)
)

cat(summary_output)

# Save EDA report
sink("reports/EDA_SUMMARY.txt")
cat(summary_output)
sink()

cat("\n✓ All EDA outputs saved\n")
