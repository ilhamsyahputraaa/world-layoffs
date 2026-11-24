-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging4;


SELECT MAX(total_laid_off)
FROM layoffs_staging4;


-- Most Layoffs Company
SELECT company, sum(total_laid_off)
FROM layoffs_staging4
GROUP BY company
ORDER BY 2 DESC;


-- Most Layoffs Industry
SELECT industry, sum(total_laid_off)
FROM layoffs_staging4
GROUP BY industry
ORDER BY 2 DESC;


-- Most Layoffs Country
SELECT Country, sum(total_laid_off)
FROM layoffs_staging4
GROUP BY Country
ORDER BY 2 DESC;

-- Start from to
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging4;


-- Most Layoffs Year
SELECT YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging4
GROUP BY  YEAR(`date`)
ORDER BY 1 DESC;

-- Most Layoffs Month
SELECT SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY `MONTH`
ORDER BY 2 DESC ;

-- Most Layoffs Month Year
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY `MONTH`
ORDER BY 2 DESC ;

-- Layoff per month rolling total
WITH rolling_total AS (

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging4
GROUP BY `MONTH`
ORDER BY 1 ASC )
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total_data
FROM rolling_total;




-- Most Layoffs Company Peryear (RANK
WITH Company_Year (company, years, total_laid_off) AS (
SELECT company, YEAR(`date`),sum(total_laid_off)
FROM layoffs_staging4
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC), Company_Year_Rank AS 
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE YEARS IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;
