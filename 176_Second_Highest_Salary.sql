# Write your MySQL query statement below
-- METHOD 1
-- SELECT MAX(e1.salary) AS SecondHighestSalary
-- FROM Employee e1 INNER JOIN Employee e2
-- ON e1.salary < e2.salary

-- This logic just above ensures 2nd highest salary is present in first table as the logic is simple - the higher salary compared to e1 would be present in e2. For example: if in e1 its 100, then correspondingly in e2 it would be 200. So highest salary in e1 would be just lower than the actual highest salary in e2 table.
-- Therefore, if we take the highest salary in e2 table it would be the 2nd highest salary in actual table. 
-- INNER JOIN handles the null cases itself

-- ____________________________________________________________________________________________________
-- METHOD 2 - using offset (skips certain rows genrally used with LIMIT)
-- example if you write limit 10 offset 20, then it will skip the first 20 rows and then choose the next 10

-- SELECT
-- (
--     SELECT DISTINCT salary FROM Employee
--     ORDER BY salary DESC
--     LIMIT 1 OFFSET 1
-- ) AS SecondHighestSalary

-- __________________________________________________________________________________________
-- METHOD 3

SELECT MAX(salary) AS SecondHighestSalary
FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee)