# Write your MySQL query statement below
WITH weight_tracker AS (
    SELECT *,
    SUM(weight) OVER (ORDER BY turn) AS cumulative_weight FROM Queue
)
SELECT person_name
FROM weight_tracker
WHERE cumulative_weight <= 1000
ORDER BY turn DESC
LIMIT 1

-- ### Given Table: `Queue`

-- | person_id | person_name | weight | turn |
-- |-----------|-------------|--------|------|
-- | 5         | Alice       | 250    | 1    |
-- | 4         | Bob         | 175    | 5    |
-- | 3         | Alex        | 350    | 2    |
-- | 6         | John Cena   | 400    | 3    |
-- | 1         | Winston     | 500    | 6    |
-- | 2         | Marie       | 200    | 4    |

-- ---

-- #Step 1: CTE — `weight_tracker`

-- ```sql
-- WITH weight_tracker AS (
--     SELECT *,
--            SUM(weight) OVER (ORDER BY turn) AS cumulative_weight
--     FROM Queue
-- )
-- ```

-- - Here, we're using a **window function**:  
--   `SUM(weight) OVER (ORDER BY turn)`  
--   This calculates the **cumulative sum of weights** in the order of turns.

-- Let’s simulate what the CTE `weight_tracker` looks like:

-- | person_id | person_name | weight | turn | cumulative_weight |
-- |-----------|-------------|--------|------|--------------------|
-- | 5         | Alice       | 250    | 1    | 250                |
-- | 3         | Alex        | 350    | 2    | 600 (250+350)      |
-- | 6         | John Cena   | 400    | 3    | 1000 (600+400)     |
-- | 2         | Marie       | 200    | 4    | 1200 (1000+200)    |
-- | 4         | Bob         | 175    | 5    | 1375 (1200+175)    |
-- | 1         | Winston     | 500    | 6    | 1875 (1375+500)    |

-- ---

-- #Step 2: Main Query

-- ```sql
-- SELECT person_name
-- FROM weight_tracker
-- WHERE cumulative_weight <= 1000
-- ORDER BY turn DESC
-- LIMIT 1;
-- ```

-- - This filters only the people who **can board** the bus (i.e. their cumulative weight ≤ 1000):

-- | person_name | turn | cumulative_weight |
-- |-------------|------|--------------------|
-- | Alice       | 1    | 250                |
-- | Alex        | 2    | 600                |
-- | John Cena   | 3    | 1000               |

-- - Then, it sorts this filtered list in **descending `turn` order**, and picks the **top row** (`LIMIT 1`) to get the **last person who can board** the bus.

-- Final Output:

-- | person_name |
-- |-------------|
-- | John Cena   |

-- ---

-- ### Summary:

-- | Component     | Purpose                                                                 |
-- |---------------|-------------------------------------------------------------------------|
-- | `SUM(...)`    | Calculates running total of weight as people board.                     |
-- | CTE           | Prepares a table with cumulative weights per person in order of `turn`. |
-- | Main query    | Filters valid boarders and finds the last person who can still fit.     |