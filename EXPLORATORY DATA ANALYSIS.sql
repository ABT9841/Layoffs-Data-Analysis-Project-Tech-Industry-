--  -----  Exploratory Data Analysis.  ----------------------

-- checking the max nuumber
select MAX(percentage_laid_off) , MAX(total_laid_off) 
from layoffs_staging_2;

-- 1 means the 100% laid off.
-- finding the layoffs on the basis of max total_laid_off and funds_raised 
SELECT *
FROM layoffs_staging_2 
where percentage_laid_off = 1
-- order by total_laid_off desc; 
order by funds_raised desc; -- 2400 means 2.4 billions.

-- finding which company has the maximum number of laid off
SELECT company , sum(total_laid_off)
FROM layoffs_staging_2 
group by company
order by 2 desc;

-- finding date range we have here. we found out the data was of 3 years.
select min(`date`), max(`date`)
from layoffs_staging_2;

-- finding which industry  has the most layoffs. 
select industry , sum(total_laid_off) 
from layoffs_staging_2
group by industry 
order by 2 desc ; -- consumer has the maximum number of layoffs and manufacuturing is the lowest.

-- finding which country has the highest number of laidoffs.
select country , sum(total_laid_off)
from layoffs_staging_2
group by country 
order by 2 desc; -- us has the most.

-- finding out which year has the most laid offs.
select year(`date`), sum(total_laid_off)  -- 2022 has the maximum numbers of layoffs.
from layoffs_staging_2
group by year(`date`)
order by 1 desc;

-- finding out in which stage(here means funding stage starts with seed and goes up til ipo) . does the company has the maximum numbers of layoffs.
select stage, sum(total_laid_off)
from layoffs_staging_2
group by stage
order by 2 desc;   -- most are coming from post ipo

-- the percentage of the laidoffs is not that important.

-- getting the  YEAR WITH month from date columns
SELECT SUBSTRING(`date`,1,7)  as `MONTH`, SUM(total_laid_off) -- starts from position 6 and just take 2 values after that.	
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL	  
group by `MONTH`
ORDER BY 1 aSC;


-- we are going to do the rolling  sum of the total laid off with ctes
with Rolling_Total as (
select substring(`date`,1,7) as `month` , sum(total_laid_off) as total_off
from layoffs_staging_2
where substring(`date`, 1,7 ) is not null
group by `month`
order by 1 asc
)
select `month`, total_off, sum(total_off) over( order by `month`) 	as rolling_total
from Rolling_Total;

-- we are going to look at  the company that has the maximum laid off in a year.
-- the highest one based of the year will be rank the most.
select company , year(`date`),sum(total_laid_off)
from layoffs_staging_2
where year(`date`) is not null
group by company ,year(`date`)
order  by 2 ;





