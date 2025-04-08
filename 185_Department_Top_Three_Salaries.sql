# Write your MySQL query statement below
-- SELECT
--     d.name AS Department,
--     e1.name AS Employee,
--     e1.salary AS Salary
-- FROM Employee e1 INNER JOIN Department d
-- ON e1.departmentId = d.id
-- WHERE 3 >
-- (
--     SELECT COUNT(DISTINCT(e2.Salary))
--     FROM Employee e2
--     WHERE e2.Salary > e1.Salary
--     AND
--     e1.DepartmentId = e2.DepartmentId
-- )
-- TC -> O(N^2)
-- The Key Detail: COUNT(DISTINCT e2.salary)
-- This is not counting the number of people, it is counting the number of unique salaries greater than e1.salary.
-- So even if 5 people have the same salary — that counts as only 1 unique salary.

-- ____________________________________________________________________________________________

-- 2nd Method -> using DENSE_RANK()
-- Unlike ROW_NUMBER(), DENSE_RANK() doesn't skip ranks when there are duplicates.

WITH RankedSalaries AS
(
    SELECT
    d.name AS Department,
    e.name AS Employee,
    e.salary AS Salary,
    DENSE_RANK() OVER (
        PARTITION BY e.departmentId
        ORDER BY e.salary DESC
    ) AS salary_rank
    FROM Employee e
    JOIN Department d
    ON e.departmentId = d.id
)
SELECT Department, Employee, Salary
FROM RankedSalaries
WHERE salary_rank <= 3

-- PARTITION BY ensures that each department is treated differently and assigned a rank
-- ORDER BY sorts the salaries in descending order
-- As DENSE_RANK() allows for duplicate ranking, when salary_rank <= 3 is provided it satisfies the given constraints