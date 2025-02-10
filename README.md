# Layoffs-Data-Analysis-Project-Tech-Industry-

## 📌 Project Overview
This project focuses on analyzing layoffs in the tech industry using SQL. The dataset, sourced from Kaggle ([Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)), contains **2,361 rows**. The goal is to showcase **data wrangling, cleaning, and transformation** skills using MySQL Workbench.


## 🛠 Tools Used
- **Database:** MySQL Workbench
- **Dataset:** Kaggle Layoffs 2022
- **SQL Techniques:** CTEs, Window Functions, Temporary Tables, Data Cleaning

---

## 🔹 Step 1: Database & Table Setup
1. **Created a new database** (`layoffs_db`).
2. **Imported the dataset** using the "Table Data Import Wizard" (no changes to data types initially).
3. **Created a staging table** (`layoffs_staging`) to keep the raw data unchanged.

```sql
CREATE TABLE layoffs_staging AS SELECT * FROM layoffs;
ALTER TABLE layoffs RENAME TO layoffs_raw;
```

---

## 🔹 Step 2: Data Cleaning
### **1️⃣ Removing Duplicates**
- Used **ROW_NUMBER()** (a window function) to identify duplicate records.
- Deleted rows where `row_num > 1`.

```sql
WITH duplicates_cte AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY company, industry, location, date ORDER BY id) AS row_num
    FROM layoffs_staging
)
DELETE FROM layoffs_staging WHERE id IN (
    SELECT id FROM duplicates_cte WHERE row_num > 1
);
```

✅ **Result:** 5 duplicate rows removed.

---

### **2️⃣ Standardizing Data**
#### *Trimming Whitespaces*
- Removed extra spaces from `company` column.

```sql
UPDATE layoffs_staging SET company = TRIM(company);
```
✅ **Result:** 11 rows updated.

#### *Fixing Industry Naming Inconsistencies*
- Found inconsistent naming in **'Crypto Currencies'** industry.
- Updated 3 rows to maintain uniformity.

```sql
UPDATE layoffs_staging SET industry = 'Crypto' WHERE industry LIKE '%Crypto%';
```
✅ **Result:** 3 rows corrected.

#### *Fixing Country Name Inconsistencies*
- Found variations of **United States** (e.g., `United States.` with a trailing dot).
- Used `TRIM()` and `TRAILING` to fix inconsistencies.

```sql
UPDATE layoffs_staging SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';
```
✅ **Result:** 4 rows corrected.

---

### **3️⃣ Handling NULL & Blank Values**
#### *Industry Column Fixes*
- Found **4 rows** where `industry` was blank/null.
- Used **self-join** to populate missing values from similar records.

```sql
UPDATE layoffs_staging l1
JOIN layoffs_staging l2 ON l1.company = l2.company
SET l1.industry = l2.industry
WHERE l1.industry IS NULL OR l1.industry = '';
```
✅ **Result:** 4 missing industries populated.

#### *Handling NULLs in `total_laid_off` & `percentage_laid_off`*
- If both `total_laid_off` and `percentage_laid_off` were NULL, the row was removed.

```sql
DELETE FROM layoffs_staging WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```
✅ **Result:** 361 rows deleted.

---

## 🔹 Step 3: Data Type Transformations
1. **Formatted Date Column** (`date` was in text format → changed to `DATE`).
2. **Converted `total_laid_off` to INTEGER**.

```sql
ALTER TABLE layoffs_staging MODIFY COLUMN date DATE;
ALTER TABLE layoffs_staging MODIFY COLUMN total_laid_off INT;
```
✅ **Result:** Data types successfully updated.

---

## 📊 Final Dataset Summary
After data cleaning, the dataset now has:
- ✅ **Cleaned & standardized records**
- ✅ **No duplicates, blank values, or inconsistent data**
- ✅ **Proper data types for accurate analysis**

---

## 🎯 Key Learnings
- **Used CTEs** for better readability.
- **Implemented window functions** for duplicate removal.
- **Standardized data using SQL functions** (`TRIM()`, `UPPER()`, `LOWER()`).
- **Handled NULL values effectively**.
- **Maintained raw data integrity** while transforming staging tables.

---


---

## 📂 Folder Structure
```
📂 SQL-Layoffs-Project
 ├── 📜 README.md  (This File)
 ├── 📜 layoffs_cleaning.sql  (All SQL Queries Used)
 ├── 📊 layoffs_raw.csv  (Original Dataset)
 ├── 📊 layoffs_cleaned.csv  (Cleaned Dataset)
```

---

## 🤝 Connect with Me
If you found this project useful, feel free to connect with me on **[https://www.linkedin.com/in/alish-thapa-4a874127a/](#)** or check out my other **[https://github.com/ABT9841?tab=repositories](#)**! 🚀

