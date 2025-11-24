This repository contains two SQL scripts that document the process of cleaning, and exploring a dataset on tech layoffs.

The primary goal of this analysis is to identify trends in job cuts across different companies, industries, and time periods.

---

## 1. Cleaning Data.sql

This script outlines a comprehensive Data Cleaning process performed on the raw `layoffs` table to prepare it for analysis.

### Data Cleaning Steps Performed:

1.  **Staging Table Creation:**
    * Created a duplicate table, `layoffs_staging`, from the raw `layoffs` table to ensure data integrity during the cleaning process.
    * A final working table, `layoffs_staging2`, was created to incorporate a `row_num` column for identifying duplicates.

2.  **Duplicate Removal:**
    * Used the `ROW_NUMBER() OVER(PARTITION BY ...)` window function to assign a unique number to rows grouped by key columns (`company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `stage`, `country`, `funds_raised_millions`, `date`).
    * Rows with a `row_num` greater than 1 were identified as duplicates and subsequently deleted from `layoffs_staging2`.

3.  **Data Standardization:**
    * Text Cleaning: Used the `TRIM()` function to remove leading/trailing whitespace from the `company` column.
    * Industry Consolidation: Consolidated similar industry names (e.g., all variations of 'Crypto%' were updated to simply 'Crypto').
    * Country Cleaning: Used `TRIM(TRAILING '.' FROM country)` to fix inconsistent entries (e.g., removing the trailing period from 'United States.').
    * Date Formatting: Converted the text-based `date` column into a proper `DATE` data type using `STR_TO_DATE()` and then modified the column type using `ALTER TABLE`.

4.  **Handling Null/Blank Values:**
    * Standardized Blanks to NULLs: Blank `industry` fields (`''`) were updated to `NULL`.
    * Imputing Missing Industry Data: Joined the table to itself (`t1` and `t2`) on the `company` name to fill in missing (NULL) `industry` values** based on existing data for the same company.

5.  **Row Deletion:**
    * Rows where both `total_laid_off` and `percentage_laid_off` were `NULL` (meaning no relevant layoff data was present) were deleted.

6.  **Final Cleanup:**
    * The temporary `row_num` column was dropped from the final `layoffs_staging2` table.

---

## 2. 📈 `Exploring Data.sql`

This script focuses on exploratory data analysis using the cleaned `layoffs_staging2` table to find key layoff trends.

### Key Analysis Queries:

| Summary Statistics | Finds the maximum number and maximum percentage of total layoffs. 
| Top Companies | Calculates the total number of employees laid off by each company and ranks them in descending order. 
| Yearly Trends | Calculates the total number of layoffs aggregated by the year. 
| Monthly Trends | Calculates the total number of layoffs aggregated by month (`YYYY-MM`). 
| Rolling Totals (Time Series) | Uses a Common Table Expression (CTE) and a window function (`SUM() OVER(ORDER BY MONTH)`) to calculate a running (cumulative) total of laid-off employees over time. 


