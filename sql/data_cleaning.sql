-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Edit Data types
-- 4. Null Values or Blank Values
-- 5. Remove any columns or rows that we dont need

-- ------------------------------------------

-- Import to staging data

select COUNT(*)
FROM layoffs_updated;

CREATE TABLE layoffs_staging3
LIKE layoffs_updated;

SELECT *
FROM layoffs_staging3;

INSERT layoffs_staging3
SELECT *
FROM layoffs_updated;


-- -------------------------------------------

-- 1. Check the duplicates


SELECT *
FROM layoffs_staging3;

SELECT COUNT(*)
FROM layoffs_staging3;

SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num 
FROM layoffs_staging3;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num 
FROM layoffs_staging3
)
SELECT * -- gabisa langsung delete karna ini update ke database, jadi harus bikin table baru dan tambahin row
FROM duplicate_CTE
WHERE row_num > 1;


CREATE TABLE `layoffs_staging4` (
  `company` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `total_laid_off` int DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `percentage_laid_off` double DEFAULT NULL,
  `industry` varchar(50) DEFAULT NULL,
  `stage` varchar(50) DEFAULT NULL,
  `funds_raised` int DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `row_num` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;




SELECT *
FROM layoffs_staging4;

INSERT INTO layoffs_staging4
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num 
FROM layoffs_staging3;


SET SQL_SAFE_UPDATES = 0;


SELECT * 
FROM layoffs_staging4
WHERE row_num > 1;

DELETE
FROM layoffs_staging4
WHERE row_num >1;


SELECT *
FROM layoffs_staging4;


-- ------------------------------------------------

-- Standardizing data


SELECT company
FROM layoffs_staging4;


UPDATE layoffs_staging4
SET company = TRIM(company);

SELECT * 
FROM layoffs_staging4
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging4
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging4
ORDER BY 1;

UPDATE layoffs_staging4
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- -------------------------

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging4;

SELECT company, `date`
FROM layoffs_staging4
WHERE `date` = 'NULL' or '';

UPDATE layoffs_staging4
SET `date` = NULL
WHERE `date` = 'NULL' or '';

UPDATE layoffs_staging4
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL
  AND `date` <> '';


SELECT `date`
FROM layoffs_staging4;



-- ---------------------------
-- EDIT DATA TYPES

ALTER TABLE layoffs_staging4
MODIFY COLUMN `date` DATE;


UPDATE layoffs_staging4
SET total_laid_off = NULL
WHERE total_laid_off = 'NULL';

ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off int DEFAULT NULL;


-- ----------------------------

-- NULL AND BLANKS



SELECT *
FROM layoffs_staging4 t1
JOIN layoffs_staging4 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;




-- -------------------------------------

-- Delete Column

ALTER TABLE layoffs_staging4
DROP COLUMN row_num;


SELECT *
FROM layoffs_staging4;



