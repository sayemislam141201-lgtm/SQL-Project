-- Data CLeaning 

SELECT *
FROM layoffs;

-- 1) Remove Duplicates 
-- 2) Stadardise the data 
-- 3) Null values or Blank values
-- 4) Remove any columns 

-- Create duplicate table so dont have to work with raw data 
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Removing Duplicates 

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, stage, country, funds_raised_millions, `date`) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1; -- If row_num > 1 then they are duplicates

-- You cant update or delete a cte so create new table with row_num
-- Copy layoffs_staging to clipboard 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 
SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, stage, country, funds_raised_millions, `date`) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardising the data
SELECT company, TRIM(company)
FROM layoffs_staging2;

SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY 1;       

UPDATE Layoffs_staging2 -- Theres 3 different Cryptos so make them all the same 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1; 

UPDATE Layoffs_staging2 -- 2 different United States one had '.' at the end
SET country = TRIM(TRAILING '.' FROM country) 
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') -- Converts to date format
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- NULL or Blank Values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'; -- Can see that the other Airbnbs falls under the travel insdustry so can fill out the NULL ones

UPDATE layoffs_staging2   -- Changing all the blank values into NULL values
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry 
FROM layoffs_staging2 t1 -- (Table 1)
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company 
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- Now update the values 
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

DELETE                                  -- Deleting the unimportant rows
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
