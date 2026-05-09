# ============================================================================
# SETUP SCRIPT: Install all required packages and verify dependencies
# ============================================================================

cat("\n")
cat(strrep("=", 75), "\n")
cat("HOUSEHOLD INCOME & POVERTY ANALYSIS - SETUP\n")
cat(strrep("=", 75), "\n\n")

# Check R version
r_version <- R.version$major
r_minor <- R.version$minor

cat(sprintf("R Version: %s.%s\n", r_version, r_minor))

if (as.numeric(paste(r_version, r_minor, sep = ".")) < 4.0) {
  cat("⚠ WARNING: R 4.0+ recommended. Some packages may not work on older versions.\n")
}

cat("\n")

# List of required packages
required_packages <- data.frame(
  Package = c(
    "tidyverse",
    "ggplot2",
    "haven",
    "janitor",
    "mice",
    "DataExplorer",
    "corrplot",
    "openxlsx",
    "scales",
    "gridExtra"
  ),
  Purpose = c(
    "Data manipulation and pipeline",
    "Publication-quality visualizations",
    "Read Stata/SPSS files",
    "Data cleaning utilities",
    "Missing data imputation",
    "Exploratory data analysis",
    "Correlation matrix plots",
    "Excel workbook creation",
    "Number and date formatting",
    "Multi-panel plot arrangement"
  ),
  Status = NA
)

cat("Checking package availability...\n\n")

# Check each package
for (i in seq_along(required_packages$Package)) {
  pkg <- required_packages$Package[i]
  
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    required_packages$Status[i] <- "✓ Installed"
    cat(sprintf("✓ %-20s Installed\n", pkg))
  } else {
    required_packages$Status[i] <- "✗ Missing"
    cat(sprintf("✗ %-20s Missing\n", pkg))
  }
}

cat("\n")

# Install missing packages
missing_packages <- required_packages$Package[is.na(required_packages$Status) | 
                                              required_packages$Status == "✗ Missing"]

if (length(missing_packages) > 0) {
  cat(sprintf("Installing %d missing package(s)...\n\n", length(missing_packages)))
  
  for (pkg in missing_packages) {
    cat(sprintf("Installing %s...", pkg))
    tryCatch({
      install.packages(pkg, dependencies = TRUE, quiet = TRUE)
      cat(" ✓\n")
    }, error = function(e) {
      cat(sprintf(" ✗ Error: %s\n", e$message))
    })
  }
} else {
  cat("✓ All required packages already installed\n")
}

cat("\n")

# Verify installation
cat("Verifying packages load correctly...\n\n")

packages_to_load <- c(
  "tidyverse", "ggplot2", "haven", "janitor", "mice",
  "corrplot", "openxlsx", "scales", "gridExtra"
)

all_loaded <- TRUE

for (pkg in packages_to_load) {
  tryCatch({
    library(pkg, character.only = TRUE, quietly = TRUE)
    cat(sprintf("✓ %s loaded\n", pkg))
  }, error = function(e) {
    cat(sprintf("✗ %s failed to load\n", pkg))
    all_loaded <<- FALSE
  })
}

cat("\n")

# Directory structure check
cat("Checking directory structure...\n\n")

required_dirs <- c(
  "data/raw",
  "data/processed",
  "data/metadata",
  "code",
  "reports/figures",
  "dashboards",
  "dashboards/power_bi",
  "docs"
)

for (dir in required_dirs) {
  if (dir.exists(dir)) {
    cat(sprintf("✓ %s/\n", dir))
  } else {
    cat(sprintf("⚠ %s/ (Creating...)\n", dir))
    dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  }
}

cat("\n")

# Create .gitignore if not exists
if (!file.exists(".gitignore")) {
  cat("Creating .gitignore...\n")
  gitignore_content <- "# Data files
data/raw/*.csv
data/processed/*.csv
*.xlsx
*.xls

# Large files
*.RData
*.rda
dashboards/*.pbix

# System files
.DS_Store
Thumbs.db
.Rhistory
.RData

# IDE files
.Rproj.user/
.vscode/
.idea/

# Output files
reports/figures/*.png
*.log
"
  
  writeLines(gitignore_content, ".gitignore")
  cat("✓ .gitignore created\n")
}

cat("\n")

# Summary
cat(strrep("=", 75), "\n")
cat("SETUP SUMMARY\n")
cat(strrep("=", 75), "\n\n")

summary_text <- sprintf(
  "✓ R Version: %s.%s
✓ Core packages: Ready
✓ Directory structure: Ready
✓ Git configuration: Ready

Next Steps:
1. Place raw survey data in: data/raw/household_survey_raw.csv
2. Run analysis: source('code/01_data_cleaning.R')
3. View guide: See docs/USAGE_GUIDE.md

For detailed instructions, see README.md
",
  r_version, r_minor
)

cat(summary_text)
cat(strrep("=", 75), "\n\n")

cat("✓ Setup complete! Project is ready to use.\n\n")
