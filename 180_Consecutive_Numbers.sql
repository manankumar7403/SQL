# Write your MySQL query statement below
-- SELECT DISTINCT l1.num AS ConsecutiveNums FROM Logs l1
-- JOIN Logs l2 ON l1.id = l2.id - 1
-- JOIN Logs l3 ON l1.id = l3.id - 2
-- WHERE l1.num = l2.num AND l2.num = l3.num

-- ___________________________________________________________________________________________

-- Now this method works only becuase it is mentioned that id is an autoincrement column starting from 1
-- If that's not the case, we can use lead and lag functions

SELECT DISTINCT num AS ConsecutiveNums
FROM (
    SELECT num,
           LAG(num, 1) OVER (ORDER BY id) AS prev1,
           LAG(num, 2) OVER (ORDER BY id) AS prev2
    FROM Logs
) AS sub
WHERE num = prev1 AND num = prev2

-- Let's walk through an example where the `id` column is **not in perfect order**, and see **why using `LAG()` is necessary**, and how it correctly finds 3 consecutive numbers.

-- Example Logs table (unordered id):

-- | id | num |
-- |----|-----|
-- | 11 | 1   |
-- | 5  | 1   |
-- | 3  | 1   |
-- | 7  | 2   |
-- | 20 | 1   |
-- | 8  | 2   |
-- | 21 | 2   |

-- Here, the `id`s are **not sequential or sorted**, but we **still want to detect if any number appears 3 times in a row in order of `id`**.

-- ---

-- ### Step 1: Sort by `id`

-- Window functions like `LAG()` operate **based on ordering**. We’ll sort by `id`, so we get the “logical” order of rows:

-- | row | id | num |
-- |-----|----|-----|
-- | 1   | 3  | 1   |
-- | 2   | 5  | 1   |
-- | 3   | 7  | 2   |
-- | 4   | 8  | 2   |
-- | 5   | 11 | 1   |
-- | 6   | 20 | 1   |
-- | 7   | 21 | 2   |

-- ---

-- ### Step 2: Use `LAG()` to peek back

-- Apply the `LAG()` function to compare the current `num` with the two previous values:

-- | id | num | prev1 | prev2 |
-- |----|-----|-------|--------|
-- | 3  | 1   | null  | null   |
-- | 5  | 1   | 1     | null   |
-- | 7  | 2   | 1     | 1      |
-- | 8  | 2   | 2     | 1      |
-- | 11 | 1   | 2     | 2      |
-- | 20 | 1   | 1     | 2      |
-- | 21 | 2   | 1     | 1      |

-- ---

-- ### Step 3: Check for 3 in a row

-- Only when:

-- ```sql
-- num = prev1 AND num = prev2
-- ```

-- ...do we have 3 same numbers in a row. From the table above, **no row** meets that condition, so the result is **empty**.

-- ---

-- ### Final Query Recap:

-- ```sql
-- SELECT DISTINCT num AS ConsecutiveNums
-- FROM (
--     SELECT num,
--            LAG(num, 1) OVER (ORDER BY id) AS prev1,
--            LAG(num, 2) OVER (ORDER BY id) AS prev2
--     FROM Logs
-- ) AS sub
-- WHERE num = prev1 AND num = prev2;
-- ```

-- ---

-- ### Why not use `l1.id = l2.id - 1`?

-- In our example, `id` goes: 3 → 5 → 7 → 8 → 11...

-- You can't rely on subtracting 1 to get the "previous" row, because there's no guarantee that `id` values are continuous — **this would miss valid consecutive values**.


-- __________________________________________________________________________________________

-- ## 🔁 `OVER` Clause (The Foundation)

-- The `OVER` clause defines a **"window"** of rows for a function to operate over.

-- You typically use it with:

-- - Aggregates: `SUM()`, `AVG()`, etc.
-- - Ranking: `ROW_NUMBER()`, `RANK()`
-- - Navigation: `LEAD()`, `LAG()`

-- ### Syntax:

-- ```sql
-- <function>() OVER (
--     PARTITION BY <column>   -- optional: groups within the data
--     ORDER BY <column>       -- defines the order of rows
-- )
-- ```

-- ---

-- ## ⬅️ `LAG(column, offset, default)`

-- Returns the **value from a previous row** in the specified window.

-- - `column`: The column to look at.
-- - `offset`: How many rows behind to look (default is 1).
-- - `default`: What to return if there's no such row (optional).

-- ### Example:

-- ```sql
-- SELECT
--     id,
--     num,
--     LAG(num, 1) OVER (ORDER BY id) AS prev_num
-- FROM Logs;
-- ```

-- > This gives the previous `num` based on `id` order.

-- ---

-- ## ➡️ `LEAD(column, offset, default)`

-- Returns the **value from a future row** in the specified window.

-- ### Example:

-- ```sql
-- SELECT
--     id,
--     num,
--     LEAD(num, 1) OVER (ORDER BY id) AS next_num
-- FROM Logs;
-- ```

-- > This gives the next `num` after the current row, based on `id`.

-- ---

-- ## 🧠 Full Example:

-- Imagine this table:

-- | id | num |
-- |----|-----|
-- | 1  | 100 |
-- | 2  | 200 |
-- | 3  | 200 |
-- | 4  | 100 |
-- | 5  | 300 |

-- Query:

-- ```sql
-- SELECT
--     id,
--     num,
--     LAG(num, 1) OVER (ORDER BY id) AS prev_num,
--     LEAD(num, 1) OVER (ORDER BY id) AS next_num
-- FROM Logs;
-- ```

-- Output:

-- | id | num | prev_num | next_num |
-- |----|-----|----------|----------|
-- | 1  | 100 | NULL     | 200      |
-- | 2  | 200 | 100      | 200      |
-- | 3  | 200 | 200      | 100      |
-- | 4  | 100 | 200      | 300      |
-- | 5  | 300 | 100      | NULL     |

-- ---

-- ## 🚀 Real-Life Use Cases

-- - Detect **consecutive duplicates** (`num = LAG(num)`)
-- - Calculate **differences between rows** (`amount - LAG(amount)`)
-- - Find **running trends** or **compare current and future values**