# 🛠️ SQL Fundamentals: NULL Handling, Constraints & Data Integrity

This document demonstrates practical SQL concepts including:

- Handling NULL values
- COUNT behavior differences
- Table copying techniques
- DELETE vs TRUNCATE vs DROP
- ISNULL vs COALESCE vs NULLIF
- Constraints and data integrity
- Exception handling (division by zero prevention)
- 

## 📌 1️⃣ Handling NULL Values

### 🔎 Theory

`NULL` represents missing or unknown data. It is NOT zero, empty string, or false.

Key rules:
- You cannot use `=` to compare NULL.
- Use `IS NULL` or `IS NOT NULL`.
- NULL values impact aggregations and calculations.
- Improper NULL handling can silently produce incorrect analytical results.

---

### Create Sample Table

```sql
CREATE TABLE emps (
    id INT NULL,
    name VARCHAR(50) NULL,
    location VARCHAR(50) NULL,
    salary DECIMAL(10,2) NULL
);
```

### Insert Sample Data

```sql
INSERT INTO emps (id, name, location, salary)
VALUES
(NULL, 'Amit', 'Bangalore', 50000),
(2, NULL, 'Mumbai', 60000),
(3, 'Ravi', NULL, 55000),
(4, 'Sneha', 'Delhi', NULL),
(NULL, NULL, 'Chennai', 45000),
(6, 'Priya', NULL, NULL),
(NULL, 'Karan', 'Hyderabad', NULL),
(8, NULL, NULL, 70000),
(9, 'Neha', 'Pune', 65000),
(NULL, NULL, NULL, NULL),
(11, 'Arjun', 'Kolkata', 52000),
(12, 'Meera', NULL, 48000),
(NULL, 'Rahul', 'Jaipur', 51000),
(14, NULL, 'Lucknow', NULL),
(15, 'Anita', 'Ahmedabad', 58000);
```

### Finding NULL Records

```sql
SELECT * FROM emps
WHERE id IS NULL;
```

---

## 📊 2️⃣ COUNT(*) vs COUNT(column)

### 🔎 Theory

`COUNT()` follows the **Non-NULL rule**:

- `COUNT(*)` → Counts all rows  
- `COUNT(column_name)` → Counts only non-NULL values  
- `COUNT(1)` → Same as `COUNT(*)`

This distinction is critical in analytics because NULL values can change business metrics.

---

```sql
SELECT COUNT(*) FROM emps;     
SELECT COUNT(id) FROM emps;    
SELECT COUNT(1) FROM emps;     
SELECT COUNT(-100) FROM emps;
```

### Percentage of NULL vs NOT NULL

```sql
SELECT 
    ROUND((CAST(COUNT(name) AS FLOAT)/COUNT(*)),2) AS perc_not_null_names,
    1 - ROUND((CAST(COUNT(name) AS FLOAT)/COUNT(*)),2) AS perc_null_names
FROM emps;
```

---

## 📂 3️⃣ Creating a Copy of Data

### 🔎 Theory

- `SELECT INTO` → Creates a new table and copies data.
- `INSERT INTO SELECT` → Inserts data into an existing table.

Use `SELECT INTO` for staging or quick backups.  
Use `INSERT INTO SELECT` in controlled production systems.

---

### SELECT INTO (Creates + Copies)

```sql
SELECT * INTO copy_emps
FROM emps;
```

### INSERT INTO SELECT (Table Must Exist)

```sql
CREATE TABLE abc (
    id INT NULL,
    name VARCHAR(50) NULL,
    location VARCHAR(50) NULL,
    salary DECIMAL(10,2) NULL
);

INSERT INTO abc
SELECT * FROM emps;
```

### Create Structure Only (No Data)

```sql
SELECT * INTO xyz
FROM emps
WHERE 1 = 2;
```

---

## 🗑️ 4️⃣ DELETE vs TRUNCATE vs DROP

### 🔎 Theory

| Command | Purpose |
|----------|----------|
| DELETE | Removes rows (supports WHERE) |
| TRUNCATE | Removes all rows (faster, minimal logging) |
| DROP | Removes entire table |

In production:
- Use `DELETE` for controlled removal.
- Use `TRUNCATE` for bulk reset.
- Use `DROP` cautiously.

---

```sql
TRUNCATE TABLE abc;

DELETE FROM abc WHERE id IN (12,13,14,15);

DELETE FROM abc;

DROP TABLE abc;
```

---

## 🔄 5️⃣ ISNULL

### 🔎 Theory

`ISNULL(expression, replacement)` replaces NULL with a specific value.

- SQL Server specific
- Used for reporting and cleaning outputs
- Evaluates only two arguments

---

```sql
SELECT *,
       ISNULL(name, 'Unspecified') AS names_cleaned
FROM emps;
```

Updating original table:

```sql
UPDATE copy_emps
SET name = ISNULL(name, 'Unspecified');
```

---

## 🔍 6️⃣ COALESCE

### 🔎 Theory

`COALESCE(value1, value2, ..., valueN)` returns the first non-NULL value.

- ANSI SQL standard
- Evaluates left to right
- Stops at first non-NULL
- Preferred in production code

---

```sql
SELECT *,
       ISNULL(name, 'Unspecified') AS new_name,
       COALESCE(name, 'Unspecified') AS new_c_name
FROM emps;
```

### Example: Multiple Phone Numbers

```sql
CREATE TABLE ContactNumbers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(50),
    Phone1 VARCHAR(15),
    Phone2 VARCHAR(15),
    Phone3 VARCHAR(15)
);
```

```sql
SELECT *,
       COALESCE(phone1, phone2, phone3, 'No number provided') AS callable_no
FROM ContactNumbers;
```

---

## ⚠️ 7️⃣ NULLIF (Exception Handling)

### 🔎 Theory

`NULLIF(expression1, expression2)` returns NULL if both expressions are equal.

Primarily used to:
- Prevent division-by-zero errors
- Clean placeholder values
- Implement defensive SQL logic

---

```sql
SELECT TotalSales / NULLIF(UnitsSold, 0)
FROM sales;
```

---

## 🛡️ 8️⃣ SQL Constraints

### 🔎 Theory

Constraints enforce data integrity at the database level.  
They prevent invalid or inconsistent data from entering the system.

---

### PRIMARY KEY

Ensures:
- No NULLs
- No duplicates
- Unique row identification

```sql
CREATE TABLE t100 (
    empid INT PRIMARY KEY,
    name VARCHAR(50)
);
```

---

### UNIQUE

Ensures:
- No duplicate values
- Allows one NULL (SQL Server behavior)

```sql
CREATE TABLE t200 (
    empid INT UNIQUE,
    name VARCHAR(50)
);
```

---

### FOREIGN KEY

Enforces referential integrity between tables.

- Prevents orphan records
- Maintains parent-child relationship

```sql
CREATE TABLE t300 (
    id INT FOREIGN KEY REFERENCES t200(empid),
    dept VARCHAR(50)
);
```

---

### DEFAULT

Provides fallback value during insertion.

```sql
CREATE TABLE t400 (
    id INT,
    salary INT DEFAULT(10000)
);
```

---

### CHECK

Validates logical condition before insertion.

```sql
CREATE TABLE t500 (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT CHECK(age >= 21)
);
```

---

### NOT NULL

Prevents NULL entries in a column.

```sql
CREATE TABLE t600 (
    id INT NOT NULL,
    name VARCHAR(50),
    age INT CHECK(age >= 21)
);
```

---

## 🎯 Key Takeaways

- COUNT(column) ignores NULL  
- COALESCE is more flexible than ISNULL  
- NULLIF prevents runtime errors  
- SELECT INTO creates and copies tables  
- TRUNCATE is faster than DELETE  
- Constraints protect data integrity  

