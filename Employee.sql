-- Q1(a): Find the list of employees whose salary ranges between 2L to 3L.
SELECT EmpName, Salary FROM Employee
WHERE Salary BETWEEN 200000 AND 300000

-- Q1(b): Write a query to retrieve the list of employees from the same city.
SELECT E1.EmpID, E1.EmpName, E1.City
FROM Employee E1
JOIN Employee E2 ON E1.City = E2.City
WHERE E1.EmpID != E2.EmpID;

-- Q1(c): Query to find the null values in the Employee table. 
SELECT * FROM Employee
WHERE EmpID IS NULL

-- Q2(a): Query to find the cumulative sum of employee’s salary.
SELECT EmpID, Salary, SUM(Salary) OVER (ORDER BY EmpID) AS CumulativeSum
FROM Employee;

-- Q2(b): What’s the male and female employees ratio.
SELECT
    ROUND(100.0 * SUM(CASE WHEN Gender = 'M' THEN 1 ELSE 0 END) / COUNT(*), 2) AS MalePct,
    ROUND(100.0 * SUM(CASE WHEN Gender = 'F' THEN 1 ELSE 0 END) / COUNT(*), 2) AS FemalePct
FROM Employee;

-- Q2(c): Write a query to fetch 50% records from the Employee table.
SELECT * FROM Employee
WHERE EmpID <= (SELECT COUNT(EmpID) / 2 FROM Employee);

-- Q3: Query to fetch the employee’s salary but replace the LAST 2 digits with ‘XX’
SELECT Salary,
    CONCAT(SUBSTRING(CAST(Salary AS CHAR), 1, LENGTH(CAST(Salary AS CHAR)) - 2), 'XX') AS masked_number
FROM Employee;

-- Q4: Write a query to fetch even and odd rows from Employee table.

-- Fetch even rows using MOD()
SELECT * FROM Employee
WHERE MOD(EmpID, 2) = 0;

-- Fetch odd rows using MOD()
SELECT * FROM Employee
WHERE MOD(EmpID, 2) = 1;

-- Fetch even rows using ROW_NUMBER()
SELECT * FROM
(
    SELECT *, ROW_NUMBER() OVER (ORDER BY EmpID) AS RowNumber
    FROM Employee
) AS Emp
WHERE Emp.RowNumber % 2 = 0;

-- Fetch odd rows using ROW_NUMBER()
SELECT * FROM
(
    SELECT *, ROW_NUMBER() OVER (ORDER BY EmpID) AS RowNumber
    FROM Employee
) AS Emp
WHERE Emp.RowNumber % 2 = 1;

-- Q5(a): Write a query to find all the Employee names whose name:
-- • Begin with 'A'
-- • Contains 'A' alphabet at second place
-- • Contains 'Y' alphabet at second last place
-- • Ends with 'L' and contains 4 alphabets
-- • Begins with 'V' and ends with 'A'

-- Fetch names beginning with 'A'
SELECT * FROM Employee WHERE EmpName LIKE 'A%';

-- Fetch names containing 'A' at the second place
SELECT * FROM Employee WHERE EmpName LIKE '_a%';

-- Fetch names containing 'Y' at the second last place
SELECT * FROM Employee WHERE EmpName LIKE '%y_';

-- Fetch names ending with 'L' and containing 4 alphabets
SELECT * FROM Employee WHERE EmpName LIKE '____l';

-- Fetch names beginning with 'V' and ending with 'A'
SELECT * FROM Employee WHERE EmpName LIKE 'V%a';

-- Q5(b): Write a query to find the list of Employee names which is:
-- • Starting with vowels (a, e, i, o, or u), without duplicates
-- • Ending with vowels (a, e, i, o, or u), without duplicates
-- • Starting & ending with vowels (a, e, i, o, or u), without duplicates

-- Fetch names starting with vowels (without duplicates)
SELECT DISTINCT EmpName 
FROM Employee 
WHERE EmpName REGEXP '^[aeiouAEIOU]';

-- Fetch names ending with vowels (without duplicates)
SELECT DISTINCT EmpName 
FROM Employee 
WHERE EmpName REGEXP '[aeiouAEIOU]$';

-- Fetch names starting and ending with vowels (without duplicates)
SELECT DISTINCT EmpName 
FROM Employee 
WHERE EmpName REGEXP '^[aeiouAEIOU].*[aeiouAEIOU]$';

-- Q7(a): Write a query to find duplicate records from the Employee table.
SELECT EmpID, EmpName, gender, Salary, city,
       COUNT(*) AS duplicate_count
FROM Employee
GROUP BY EmpID, EmpName, gender, Salary, city
HAVING COUNT(*) > 1;

WITH CTE AS (
    SELECT EmpID, EmpName, gender, Salary, city,
           ROW_NUMBER() OVER (PARTITION BY EmpID, EmpName, gender, Salary, city ORDER BY EmpID) AS row_num
    FROM Employee
)
DELETE FROM CTE WHERE row_num > 1;

-- Q7(b): Query to retrieve the list of employees working in same project.
WITH CTE AS
(
    SELECT e.EmpID, e.EmpName, ed.Project
    FROM Employee AS e
    INNER JOIN EmployeeDetail AS ed
    ON e.EmpID = ed.EmpID
)
SELECT c1.EmpName AS Employee1, c2.EmpName AS Employee2, c1.Project
FROM CTE c1
INNER JOIN CTE c2
ON c1.Project = c2.Project AND c1.EmpID < c2.EmpID

-- Q8: Show the employee with the highest salary for each project
SELECT ed.Project, MAX(e.Salary) AS ProjectSal
FROM Employee AS e
INNER JOIN EmployeeDetail AS ed
ON e.EmpID = ed.EmpID
GROUP BY Project
ORDER BY ProjectSal DESC;

WITH CTE AS
(
    SELECT ed.Project, e.EmpName, e.Salary,
           ROW_NUMBER() OVER (PARTITION BY ed.Project ORDER BY e.Salary DESC) AS row_rank
    FROM Employee AS e
    INNER JOIN EmployeeDetail AS ed
    ON e.EmpID = ed.EmpID
)
SELECT Project, EmpName, Salary
FROM CTE
WHERE row_rank = 1;
-- Using Aggregation and SUM()
SELECT ed.Project, SUM(e.Salary) AS TotalSalary
FROM Employee AS e
INNER JOIN EmployeeDetail AS ed
ON e.EmpID = ed.EmpID
GROUP BY Project;

-- Q9: Query to find the total count of employees joined each year
SELECT YEAR(ed.doj) AS JoinYear, COUNT(*) AS EmpCount
FROM Employee AS e
INNER JOIN EmployeeDetail AS ed ON e.EmpID = ed.EmpID
GROUP BY JoinYear
ORDER BY JoinYear ASC;

-- Q10(a): Create 3 groups based on salary column
SELECT EmpName, Salary,
CASE
    WHEN Salary > 200000 THEN 'High'
    WHEN Salary >= 100000 AND Salary <= 200000 THEN 'Medium'
    ELSE 'Low'
END AS SalaryStatus
FROM Employee;


-- Q10(b): Create groups based on cities
SELECT 
    EmpID, 
    EmpName,
    SUM(CASE WHEN City = 'Mathura' THEN Salary ELSE 0 END) AS Mathura,
    SUM(CASE WHEN City = 'Pune' THEN Salary ELSE 0 END) AS Pune,
    SUM(CASE WHEN City = 'Delhi' THEN Salary ELSE 0 END) AS Delhi
FROM 
    Employee
GROUP BY 
    EmpID, EmpName;