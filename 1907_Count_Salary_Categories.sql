# Write your MySQL query statement below
-- SELECT c.category, COUNT(a.category) AS accounts_count
-- FROM
-- (
--     SELECT 'Low Salary' AS category
--     UNION ALL
--     SELECT 'Average Salary'
--     UNION ALL
--     SELECT 'High Salary'
-- ) c
-- LEFT JOIN
-- (
--     SELECT
--         CASE
--             WHEN income < 20000 THEN 'Low Salary'
--             WHEN income <= 50000 THEN 'Average Salary'
--             ELSE 'High Salary'
--         END AS category
--     FROM Accounts
-- ) a ON c.category = a.category
-- GROUP BY c.category

-- _________________________________________________________________________________________
-- 2nd method -> easier
SELECT 'Low Salary' AS category,
        COUNT(if(income<20000,1,null)) AS accounts_count
FROM Accounts
UNION ALL
SELECT 'Average Salary',
        COUNT(if(income>=20000 and income<=50000,1,null))
FROM Accounts
UNION ALL
SELECT 'High Salary',
        COUNT(if(income>50000,1,null))
FROM Accounts