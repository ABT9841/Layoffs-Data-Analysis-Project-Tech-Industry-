----------------------------- DATA CLEANINIG--------------------------

SELECT * 
FROM layoffs;

------- We created a new table to keep the raw data unchanged.

CREATE TABLE layoffs_staging
LIKE layoffs; 

--- Table has been created with only column name. Now we have to insert the rows to the column

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

--- going to find the duplicates and remove them.
---- we dont have unique id in this table . In MSSQL it automatically creates it . now we are going to create ourselves a unique id to each row. using ctes and (window function over)
--- date is a KEYWORD . So, we have to write it in ``(backticks)

WITH duplicate_ctes AS
(
SELECT * ,row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`,stage, country, funds_raised) as row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_ctes
WHERE row_num > 1;


---- copied the create statement from layoff staging and create  a table called layoffs_staging_2. 
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

----- inserted the required data into new table from above ctes query. just added extra row column
INSERT INTO layoffs_staging_2
SELECT * ,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`,stage, country, funds_raised) as row_num
FROM layoffs_staging;

select * from layoffs_staging_2;

-- deleting the row and keeping only one record for each same row. now we can delete cause we have created a temporary table.
-- To disable the safe mode. safe mode prevents the updates and deletes without using a key column in where clause. here we us non key column row_num.
SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staging_2
WHERE row_num > 1;

-- -------------------------------------NOW STANDARDIZING THE DATA------------------------
--- MEANING FINDING ISSUES IN THE DATA AND FIXING IT. 
--- REMOVING THE WHITESPACES ON BOTH SIDES USING TRIM
--- UPDATE QUERY MODIFIES THE VALUES INSIDED THE COLUMNS NOT THE COLUMN NAME. SO WHEN I SELECT ALL COLUMN I DONT SEE CHANGE IN COLUMNS NAME WHEREAS VALUES ARE CHANGED.
UPDATE layoffs_staging_2
SET company = TRIM(COMPANY);

-- ----CHECKING INDUSTRY. we are doing this there might be same industry but misswritten, inconsistencies, 
---- if we  do that then it will help in exploratory data anlayssis and visaualizing.
SELECT industry, count(*)
FROM layoffs_staging_2
GROUP BY industry
order by 1; # 1 represents the position of the column

-- found out that example = crypto , cryptocurrriencies . these should all fall in same category but are seperate.
select industry 
from layoffs_staging_2
where industry like "crypto%";

update layoffs_staging_2
set industry = 'Crypto'
where industry like 'Crypto%';

-------- now checking distinct locations.
select distinct(location) from layoffs_staging_2 order by 1;

------ now checking for the country
select distinct country from layoffs_staging_2 order by 1;

-- on the united states there is (.)  so we are going to perfom the same like above steps BUT USING TRIM  to keep them into 1 categories.
UPDATE  layoffs_staging_2 
SET country =  TRIM(TRAILING '.' FROM COUNTRY) 
WHERE country LIKE 'United States%' ;
 
----- formatting the date into date as it was text data type.

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET `date` =STR_TO_DATE(`date`, '%m/%d/%Y');

-- NEVER DOING THIS ON RAW TABLE. WE ARE COMPLETELY CHCNIGNG DATA TYPE OF THE TABLE.
alter table layoffs_staging_2
modify column `date` DATE;



-- ------ industry has some missing and null values when we did some standarizing the data . now we are going to solve it out. -- 4 0f the row matches the condition where industry is either blank or null
select *
from layoffs_staging_2
where industry is null or industry = '';

-- -- now trying to populate the data the 4 rows that matched the conditon . at first we are trying to populate the airbnb. -------------
-- looking at the airbnb we know its travel industry as one of the data has it. 
select *
from layoffs_staging_2
where company = 'Airbnb';

-- updating blank to nulls 
set sql_safe_updates = 0;
-- 3 rows were affected and 3 changes were made.
update layoffs_staging_2
set industry = null
where industry  = '';

-- - we are going to create a table that will join on itself what we are going to check here is that, if one table is blank and other is not than fill the blank one with the non blank values.
select t1.industry , t2.industry
from layoffs_staging_2 t1 
join layoffs_staging_2 t2 
	on t1.company= t2.company and t1.location = t2.location 
where t1.industry is null and  t2.industry is not null;

-- updating rows  --- 3 rows were changed. 
update layoffs_staging_2 t1 
join layoffs_staging_2 t2
	on t1.company = t2.company 
set t1.industry= t2.industry 
where t1.industry is  null and t2.industry is not null;

-- all had been populated but there were only one row for bally so it didnt had any other poplulalted row.
select * 
from layoffs_staging_2
where industry is null;

-- ----------------  removing the null values from the laidoff and percentagelaidoffs colums as there are alot of them  in this columns. ---------
select total_laid_off, percentage_laid_off
from layoffs_staging_2
where total_laid_off is null and  percentage_laid_off is null; -- so if we have two rows are null together they are pretty useless to us. so we are going to eradiacte that cause these columns are crucial in our analysis and we dont want them to be blank or null .


-- we deleted the rows where total_laid_off or percentage_laid_off are null .  so 361 rows were deleted

delete 
from layoffs_staging_2 
where total_laid_off is null and percentage_laid_off is null;

-- now we are going to drop the column row as we have already used it to identify duplicates. keeping only relevant columns improves readability, storage efficiency, and performance.  
alter table layoffs_staging_2
drop column row_num;

select * from layoffs_staging_2
-- ----------WE DID ALL THE  CLEANING TASK
-- we remove duplicates, normalize the data, HANDLE THE MISSING AND NULL VALUES, REMOVED THE ROWS THAT WEREN'T REQUIRED.

