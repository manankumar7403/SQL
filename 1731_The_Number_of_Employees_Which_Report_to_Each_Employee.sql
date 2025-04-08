# Write your MySQL query statement below
SELECT e.employee_id, e.name, COUNT(r.employee_id) AS reports_count, ROUND(AVG(r.age)) AS average_age
FROM Employees e
JOIN Employees r
ON e.employee_id = r.reports_to
GROUP BY e.employee_id, e.name
ORDER BY e.employee_id

-- the JOIN ON e.employee_id = r.reports_to is called a self-join where you're joining a table with itself.
-- Alice and Bob report to Hercy (Hercy has employee_id = 9)
-- So, the line:
--     JOIN Employees r ON e.employee_id = r.reports_to means:
-- I want to match each manager(e) with the employees(r) who report directly to them.
-- So, if e.employee_id = 9(Hercy), then any row in Employees where reports_to = 9 (like Alice and Bob) will match. This is how we pair managers with their direct reports.
-- We're using aliases (e and r) to treat the same table as if it's two:
-- 1) e is the manager
-- 2) r is the employee reporting to that manager
-- That's why it is called a self-join - joining the table to itself.

-- Using an example:
-- Before the join
-- +-------------+---------+------------+-----+
-- | employee_id | name    | reports_to | age |
-- +-------------+---------+------------+-----+
-- | 1           | Michael | null       | 45  |
-- | 2           | Alice   | 1          | 38  |
-- | 3           | Bob     | 1          | 42  |
-- | 4           | Charlie | 2          | 34  |
-- +-------------+---------+------------+-----+

-- After the join:
-- +---------------------------+-----------------+--------------------------+-------------+------------+
-- | manager_id(e.employee_id) | manager_name    | report_id(r.employee_id) | report_name | report_age |
-- +---------------------------+-----------------+--------------------------+-------------+------------+
-- |           1               |      Michael    |         2                |     Alice   |    38      |
-- |           1               |      Michael    |         3                |     Bob     |    42      |
-- |           2               |      Alice      |         4                |     Charlie |    34      |
-- +---------------------------+-----------------+--------------------------+-------------+------------+

-- Aggregation
-- Now that we have this "expanded" table where each manager is listed alongside their direct reports, we can use aggregation:
-- COUNT(r.employee_id) -- Number of direct reports per manager
-- AVG(r.age)           -- Average age of the direct reports
-- Grouping by e.employee_id and e.name, we get:

-- employee_id	name	COUNT(r.employee_id)	AVG(r.age)
-- 1	        Michael	    2	                (38+42)/2 = 40
-- 2	        Alice	    1	                    34

-- So r is treated as the reporting employee because:
-- r.reports_to matches e.employee_id
-- That logically connects a report to their manager.

-- TL;DR
-- The join condition ensures that:
-- e is treated as the manager
-- r is treated as the employee reporting to e
-- This makes COUNT(r.employee_id) and AVG(r.age) meaningful because they count/average only those rows where r reports to e

-- Why `GROUP BY e.employee_id, e.name` is used:
-- We want one row per manager, with:
-- - their `employee_id`
-- - their `name`
-- - how many people report to them (`COUNT(r.employee_id)`)
-- - the average age of those reports (`ROUND(AVG(r.age))`)
-- To do that, we group the joined rows by the manager's identity, which is:
-- GROUP BY e.employee_id, e.name
-- This tells SQL:
-- > "Group all the report rows (from `r`) under each manager (from `e`) so we can compute summary stats (like count and average) for each manager."

-- ### 🔍 Quick example:

-- Say after the join we have this:

-- | e.employee_id | e.name    | r.employee_id | r.age |
-- |---------------|-----------|----------------|--------|
-- | 1             | Michael   | 2              | 38     |
-- | 1             | Michael   | 3              | 42     |
-- | 2             | Alice     | 4              | 34     |

-- When we `GROUP BY e.employee_id, e.name`, SQL processes this like:

-- - For Michael (ID 1):
--   - Reports: 2 → Alice (38), Bob (42)
--   - Count = 2, Avg age = 40

-- - For Alice (ID 2):
--   - Reports: 1 → Charlie (34)
--   - Count = 1, Avg age = 34

-- Purpose of `ORDER BY`
-- The clause:
-- ORDER BY e.employee_id
-- does **one simple thing**:

-- > It **sorts the final output** by the `employee_id` of the manager in ascending order (smallest to largest).

-- So the results come out **in a neat, predictable order**, like:

-- | employee_id | name    | reports_count | average_age |
-- |-------------|---------|----------------|--------------|
-- | 1           | Michael | 2              | 40           |
-- | 2           | Alice   | 1              | 34           |
-- | 3           | Bob     | ...            | ...          |

-- Is `ORDER BY` **necessary**?
-- Technically:  
-- **No** — it's **not required for correctness** of the logic or calculations.  
-- **Yes** — it's useful for **presentation** and **consistency**.

-- If you leave it out, SQL may return rows in **any order**, depending on things like indexing or how the DB processes joins internally. That’s usually not a problem for internal logic, but it’s messy for:

-- - Reports
-- - Visualizations
-- - Graders in coding challenges 😄

-- ---

-- ### 🧠 TL;DR

-- - ✅ `ORDER BY` is for **output readability**
-- - ❌ It's **not required** for your logic to work
-- - ✅ But it **is good practice** when order matters or when a problem explicitly says:  
--   _"Return the result ordered by employee_id"_