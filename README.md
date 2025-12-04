This repository contains two SQL scripts that document the process of cleaning, and exploring a dataset on job layoffs.

The primary goal of this analysis is to identify trends in job cuts across different companies, industries, and time periods.

---

## 1. Cleaning Data

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

## 2. Exploring Data
---

1.  **Purpose:**

This SQL script contains a series of exploratory queries designed to understand the structure, scale, and trends within the `layoffs_staging2` table.

The primary goals of this analysis are to:
* Identify the **maximum impact** (total layoffs and highest percentage laid off) observed in the dataset.
* Determine the **top entities** (companies and countries) contributing to the total number of layoffs.
* Establish **layoff trends over time** by year and month, including a cumulative running total.
* Analyze the **impact of layoffs by industry**.

---

2.  **Analysis Overview:**

The queries focus on aggregation functions (`SUM`, `MAX`) and time-series manipulation (`YEAR`, `SUBSTRING`) to transform individual layoff events into key business insights. The use of a **Common Table Expression (CTE)** demonstrates advanced window function capabilities for calculating cumulative totals.

---

3.  **Detailed Query Brakedown:**

   3.1  **Summary Statistics:**
| Query | Description |
| :--- | :--- |
| `SELECT * FROM layoffs_staging2;` | Basic check to preview the entire dataset structure and confirm column names/types. |
| `SELECT MAX(total_laid_off), MAX(percentage_laid_off) FROM layoffs_staging2;` | Identifies the single largest number of people laid off in any one event and the highest percentage of a company's staff laid off in one event. |

3.2 **Aggregation by Category:**
| Query | Description |
| :--- | :--- |
| `SELECT company, SUM(total_laid_off)...` | **Top Companies:** Aggregates total layoffs by company, ordered from highest to lowest impact. This is used to identify the top contributors to overall layoff numbers. |
| `SELECT country, SUM(total_laid_off)...` | **Top Countries:** Aggregates total layoffs by country, filtering out null values to ensure accuracy. This is used to identify geographical layoff hotspots. |
| `SELECT industry, TRUNCATE(SUM(percentage_laid_off),2)...` | **Industry Impact:** Calculates the sum of `percentage_laid_off` by industry, truncated to two decimal places, ordered by impact. This provides a different view of impact compared to raw counts. |

3.3  **Time Series Analysis:**

| Query | Description |
| :--- | :--- |
| `SELECT YEAR(\`date\`), SUM(total_laid_off)...` | **Yearly Trend:** Calculates the total layoffs for each year present in the dataset, ordered descending by year to show recent trends first. |
| `SELECT SUBSTRING(\`date\`, 1, 7) AS \`MONTH\`, SUM(total_laid_off)...` | **Monthly Trend:** Extracts the year and month (e.g., "YYYY-MM") and calculates the total layoffs for each month, ordered chronologically. This is the base data for the Rolling Total calculation. |

3.4  **Rolling Total Calculation:**
| Query | Description |
| :--- | :--- |
| `WITH Rolling_Total AS (...) SELECT \`MONTH\`, Total_off, SUM(total_off) OVER(...)` | **Cumulative Layoffs:** Uses a **Common Table Expression (CTE)** (`Rolling_Total`) and a **Window Function** (`SUM() OVER(...)`) to calculate the running total of layoffs month-over-month. This is crucial for visualizing the total cumulative impact over the dataset's timeline. |
