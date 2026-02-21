
-------------------------- Handling Null Values -----------------------------------------

CREATE TABLE 
emps (
		id INT NULL,
		name VARCHAR(50) NULL,
		location VARCHAR(50) NULL,
		salary DECIMAL(10,2) NULL
	  );

INSERT INTO 
emps	(id, name, location, salary) 
VALUES	(NULL, 'Amit', 'Bangalore', 50000),
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

SELECT * FROM emps;

SELECT * FROM emps 
WHERE id IS NULL;

-- COUNT (*) vs COUNT(column_name)
SELECT COUNT(*) FROM emps;		-- counts NULLs
SELECT COUNT(id) FROM emps;		-- ignores NULLs: gives count of NOT NULL records

-- The "Non-Null" Rule
-- The COUNT() function follows a very simple rule in SQL: 
-- It counts every row where the expression inside the parentheses is not NULL.

SELECT COUNT(1) FROM emps;
SELECT COUNT(-100) FROM emps;

-- Query,Logic,Result
-- COUNT(*),Counts every row (including those with all NULLs).,Total Rows
-- COUNT(1),Counts every row where 1 is not NULL.,Total Rows
-- COUNT(-100),Counts every row where -100 is not NULL.,Total Rows
-- COUNT(column_name),Counts rows where column_name is not NULL.,Varies

-- % of NULL and NOT NULL names
SELECT 
	ROUND((CAST(COUNT(name) AS FLOAT)/COUNT(*)),2) AS perc_not_null_names,
	1- ROUND((CAST(COUNT(name) AS FLOAT)/COUNT(*)),2) AS perc_null_names
FROM emps;



--------------------- Creating a copy of the Data ----------------------------

-- SELECT * INTO  vs  INSERT INTO SELECT *

-- In SELECT * INTO : The table is created and the values are copied
SELECT * INTO copy_emps
FROM emps;

-- In INSERT INTO SELECT * : The table should already exist in db
INSERT INTO abc
SELECT * FROM emps;

CREATE TABLE 
abc (
		ID INT NULL,
		Name VARCHAR(50) NULL,
		Location VARCHAR(50) NULL,
		Salary DECIMAL(10,2) NULL
	);

SELECT * FROM abc;

-- Create a table with only the skeleton: Column Names
SELECT * INTO xyz FROM emps WHERE 1=2;		--since where will never be true, no values will be added
SELECT * FROM xyz;


--------------------------------- Delete, Drop, Truncate -----------------------------------

TRUNCATE TABLE abc;		-- deletes all values at once

DELETE FROM abc WHERE id IN (12,13,14,15);	-- used to delete using WHERE condition

DELETE FROM abc;		-- DELETE FROM without WHERE : also works like truncate; but truncate is faster

DROP TABLE abc;			-- drops the table


-------------------------------- Working with NULL values ------------------------------------


-- ISNULL(check_expression, replacement_value)

-- The ISNULL function is a T-SQL (SQL Server) specific function. Other databases use IFNULL (MySQL) or NVL (Oracle).

-- Logic: It checks a single value. 
-- If that value is NULL, it replaces it with a specified value. 
-- If it is not NULL, it leaves it alone.

-- The "Why": It is a simpler, two-argument version of COALESCE. 
-- It's great for providing a default value for reports.


-- Using ISNULL to replace NULL values 

-- By creating a new column
SELECT
	*,
	ISNULL(name, 'Unspecified') AS names_cleaned		
FROM emps;

-- By updating the original column
UPDATE copy_emps
SET name = ISNULL(name, 'Unspecified');

-- or
UPDATE copy_emps
SET name = 'No Value'
WHERE name = 'Unspecified';

SELECT * FROM copy_emps;


------------------------------------- ISNULL vs COALESCE ------------------------------------------


-- COALESCE(value_1, value_2, ..., value_n)

SELECT 
	*,
	ISNULL(name, 'Unspecified') AS new_name,		-- creates new column by replacing NULLs
	COALESCE(name, 'Unspecified') AS new_c_name		
FROM emps


-- How it works:
-- The function evaluates the arguments from left to right. 
-- As soon as it finds a value that isn't NULL, it stops and returns it.
-- If every single argument is NULL, the function returns NULL.

-- COALESCE works like IF-ELIF-ELSE
-- DATA TYPE of arguments must be same

CREATE TABLE 
ContactNumbers (
					CustomerID INT PRIMARY KEY,
					Name VARCHAR(50),
					Phone1 VARCHAR(15),
					Phone2 VARCHAR(15),
					Phone3 VARCHAR(15)
				);
INSERT INTO ContactNumbers 
VALUES	(1, 'Amit', '9876543210', NULL, NULL),
		(2, 'Neha', NULL, '9123456780', NULL),
		(3, 'Rahul', NULL, NULL, '9012345678'),
		(4, 'Sneha', '9988776655', '8877665544', NULL),
		(5, 'Karan', NULL, NULL, NULL);

SELECT 
	*,
	COALESCE(phone1, phone2, phone3, 'No number provided') AS callable_no	-- returns the first non NULL value
FROM ContactNumbers;




------------------------------- Exception handling ------------------------------

-- NULLIF(expression1, expression2)

-- The NULLIF function is used to prevent errors or clean data by turning a specific value into a NULL.

-- Logic: It compares two values.
-- If they are equal, it returns NULL. 
-- If they are not equal, it returns the first value.

-- The "Why": It is most commonly used to prevent "Division by Zero" errors.

-- This will fail if UnitsSold is 0
SELECT TotalSales / UnitsSold FROM sales;

-- This returns NULL instead of crashing
SELECT TotalSales / NULLIF(UnitsSold, 0) FROM sales;


-- Function:				Plain English Goal:
-- ISNULL(A, B)				"If A is missing, use B instead."
-- NULLIF(A, B)				"If A equals B, pretend A is missing (NULL)."
-- COALESCE(A, B, C)		"Give me the first one that isn't missing."



-------------------------------- Constraints -----------------------------------

-- Constraints are the "rules" that are defined when a table is created (or modified) 
-- to ensure that the data entering the database is accurate, reliable, and consistent.

-- If a user tries to insert data that violates a constraint, 
-- the database will reject the transaction and throw an error.


-- Constraint		What it does											Real-world Example

-- PRIMARY KEY		A combination of NOT NULL and UNIQUE.					The employee_id that uniquely identifies a person.
-- UNIQUE			Ensures all values in a column are different.			No two employees can have the same email.
-- FOREIGN KEY		Prevents actions that would destroy links b/w tables.	An order must belong to a customer_id that actually exists.
-- DEFAULT			Provides a fallback value if none is specified.			If status isn't provided, set it to 'Active'.
-- CHECK			Ensures the value satisfies a specific condition.		hourly_rate must be greater than 15.
-- NOT NULL			Ensures a column cannot have a NULL value.				Every employee must have a last_name.





-- 1. PRIMARY KEY 
-- (No NULLs or duplicates:  NOT NULL and UNIQUE)

CREATE TABLE 
t100 (
		empid INT PRIMARY KEY,
		name VARCHAR(50)
	 );

INSERT INTO t100 
VALUES  (NULL, 'AYUSHI'),		
		(2, 'NISHANT');
-- ERROR: Cannot insert the value NULL into column 'empid', table 'gfg_sql_practice.dbo.t100'; column does not allow nulls. INSERT fails.


-- 2. UNIQUE
-- (No Duplicates & only 1 NULL in each column)
CREATE TABLE 
t200 (
		empid INT UNIQUE,
		name VARCHAR(50),
	 );

INSERT INTO t200 
VALUES  (NULL, 'AYUSHI'),		
		(2, 'NISHANT'),
		(NULL, 'SHRUTI');
--ERROR: Violation of UNIQUE KEY constraint 'UQ__t200__AF4CE864165A0734'. Cannot insert duplicate key in object 'dbo.t200'. The duplicate key value is (<NULL>).


-- 3. FOREIGN KEY

-- Parent-Child relationship: 
-- Table which has Foreign key is the "Child" table & 
-- Table with Primary key is the "Parent" table.
-- "No orphan rule" ie every child will have a parent.

CREATE TABLE 
t300 (
		id INT FOREIGN KEY REFERENCES t200(empid),
		dept VARCHAR(50),
	 );

INSERT INTO t300 
VALUES  (1, 'HR'),		
		(2, 'FINANCE');
-- ERROR: The INSERT statement conflicted with the FOREIGN KEY constraint "FK__t300__id__7E02B4CC". The conflict occurred in database "gfg_sql_practice", table "dbo.t200", column 'empid'.


-- 4. DEFAULT
-- If value isn't provided, set it to value mentioned in DEFAULT during table creation.

CREATE TABLE 
t400 (
		id INT,
		salary INT DEFAULT(10000)
	 );

INSERT INTO t400
VALUES  (1001, 54000),
		(1002, 60000),
		(1003, 55000),
		(1004, DEFAULT);	--10000 gets stored here

SELECT * FROM t400;


-- 5. CHECK

CREATE TABLE 
t500 (
		id INT PRIMARY KEY,
		name VARCHAR(50),
		age INT CHECK(age>=21)
	 );

INSERT INTO t500
VALUES  (1001, 'vishal', 23),
		(1002, 'ayushi', 26),
		(1003, 'nidhi', 20);
-- ERROR: The INSERT statement conflicted with the CHECK constraint "CK__t500__age__03BB8E22". The conflict occurred in database "gfg_sql_practice", table "dbo.t500", column 'age'.


-- 6. NOT NULL
-- Allows Duplicates but not NULL values

CREATE TABLE 
t600 (
		id INT NOT NULL,
		name VARCHAR(50),
		age INT CHECK(age>=21)
	 );

INSERT INTO t600
VALUES  (1002, 'vishal', 23),
		(1002, 'ayushi', 26),	-- allowed to enter this duplicate id
		(1003, 'nidhi', 25);

INSERT INTO t600
VALUES  (NULL, 'nishant', 23);
-- ERROR: Cannot insert the value NULL into column 'id', table 'gfg_sql_practice.dbo.t600'; column does not allow nulls. INSERT fails.