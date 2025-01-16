-- Data Cleanings

SELECT *
FROM layoffs;

-- 1. Remove Duplicates (If Any)
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns (sometimes we can but we shouldn't) >> so that we don't mess with raw data

-- duplicate the raw data
DROP TABLE layoffs_staging; -- remove if there is the table under this name

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. check for duplication, check if the row is unique and lack of duplication depends on the following partition.

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


INSERT INTO layoffs_staging2
SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num-- date is the keyword in SQL so using back tick
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- 2. Standardizing Data

UPDATE layoffs_staging2
SET company = TRIM(company);


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)-- Remove "." at the end
WHERE country LIKE 'United States%'; 


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- check
SELECT *
FROM layoffs_staging2;

-- 3. Working with NULL and Blank Value

-- Do self-joins to fill out the missing 'industry' where company name is the same
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4. Remove the rows and columns that we need to
-- we will be using total_laid_off and percentage_laid_off, if the value is NULL then,we are not really interested.
-- we will drop the row_num column as we don't need it anymore

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
