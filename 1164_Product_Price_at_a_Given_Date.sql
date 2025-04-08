# Write your MySQL query statement below
-- SELECT
--     p.product_id,
--     COALESCE(
--         (
--             SELECT new_price FROM Products p2
--             WHERE p2.product_id = p.product_id
--             AND p2.change_date <= '2019-08-16'
--             ORDER BY p2.change_date DESC
--             LIMIT 1
--         ),
--         10
--     ) AS price
-- FROM (SELECT DISTINCT product_id FROM Products) p

-- COALESCE returns the first non-null id from a list of expressions.
-- I sorted the change_date in descending order to ensure that the latest updated price comes out on top
-- then if the date is <= '2019-08-16', that price is taken and coalesce doesn't returns a null value, otheriwse,
-- it returns 10.
-- FROM (SELECT DISTINCT product_id FROM Products) p
-- Creates a temporary table alias p that contains only unique product_ids from the Products table.
-- It's like saying: “Give me a list of all the different products that exist.”
-- We want to ensure that every product is included in the final output, even if there were no price changes before or on 2019-08-16.

-- ____________________________________________________________________________________________

-- Using JOIN based solutions with ranked_prices CTE
WITH ranked_prices AS
(
    SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY product_id
                ORDER BY change_date DESC
            ) AS rn
    FROM Products
    WHERE change_date <= '2019-08-16'
)

SELECT
    p.product_id,
    COALESCE(r.new_price, 10) AS price
FROM
    (SELECT DISTINCT product_id FROM Products) p
LEFT JOIN ranked_prices r
ON p.product_id = r.product_id AND r.rn = 1


-- Original Table: `Products`

-- -- | product_id | new_price | change_date |
-- -- |------------|-----------|-------------|
-- -- | 1          | 20        | 2019-08-14  |
-- -- | 2          | 50        | 2019-08-14  |
-- -- | 1          | 30        | 2019-08-15  |
-- -- | 1          | 35        | 2019-08-16  |
-- -- | 2          | 65        | 2019-08-17  |
-- -- | 3          | 20        | 2019-08-18  |

-- -- ---

-- -- Step 1: CTE `ranked_prices`

-- -- ```sql
-- -- WITH ranked_prices AS (
-- --     SELECT *,
-- --            ROW_NUMBER() OVER (
-- --                PARTITION BY product_id 
-- --                ORDER BY change_date DESC
-- --            ) AS rn
-- --     FROM Products
-- --     WHERE change_date <= '2019-08-16'
-- -- )
-- -- ```

-- -- What it does:

-- -- - `WITH ranked_prices AS (...)`: This is a **Common Table Expression (CTE)** — think of it like a temporary table that you can use in the main query.
-- -- - `SELECT *`: Selects all columns from `Products`, **plus**:
-- -- - `ROW_NUMBER() OVER (...)`: Adds a new column called `rn` (row number) that assigns a rank to each row **per product**.
-- -- - `PARTITION BY product_id`: Restart the row numbers **for each product**.
-- -- - `ORDER BY change_date DESC`: Rank the most **recent price change first**.
-- -- - `WHERE change_date <= '2019-08-16'`: Only consider price changes that occurred **on or before** `2019-08-16`.

-- -- Example Output of `ranked_prices`:

-- -- | product_id | new_price | change_date | rn |
-- -- |------------|-----------|-------------|----|
-- -- | 1          | 35        | 2019-08-16  | 1  |
-- -- | 1          | 30        | 2019-08-15  | 2  |
-- -- | 1          | 20        | 2019-08-14  | 3  |
-- -- | 2          | 50        | 2019-08-14  | 1  |

-- --Product 3 is **not included** because its only price change is after `'2019-08-16'`.

-- -- ---

-- -- Step 2: Main Query

-- -- ```sql
-- -- SELECT
-- --     p.product_id,
-- --     COALESCE(r.new_price, 10) AS price
-- -- FROM
-- --     (SELECT DISTINCT product_id FROM Products) p
-- -- LEFT JOIN ranked_prices r
-- -- ON p.product_id = r.product_id AND r.rn = 1
-- -- ```

-- -- What it does:

-- -- - `(SELECT DISTINCT product_id FROM Products) p`: Gets a list of **all unique product_ids**.
-- --     - Output: 1, 2, 3
-- -- - `LEFT JOIN ranked_prices r`: Joins with the CTE `ranked_prices` (from step 1) on:
-- --     - `p.product_id = r.product_id`: Join on matching product.
-- --     - `AND r.rn = 1`: We only want the **latest price** per product from the CTE.
-- -- - `COALESCE(r.new_price, 10) AS price`: 
-- --     - If a product has a `new_price` (i.e., matched a row in the CTE), use it.
-- --     - If not (like product 3), default to `10`.

-- -- ---

-- -- ##Final Output:

-- -- | product_id | price |
-- -- |------------|-------|
-- -- | 1          | 35    | (latest price before or on 2019-08-16)
-- -- | 2          | 50    | (latest price before or on 2019-08-16)
-- -- | 3          | 10    | (no price changes before 2019-08-16, use default)

-- -- ---

-- -- #Summary

-- -- | Concept                  | Purpose                                                                 |
-- -- |--------------------------|-------------------------------------------------------------------------|
-- -- | `CTE (WITH ...)`         | Prepare a filtered + ranked version of `Products`                       |
-- -- | `ROW_NUMBER()`           | Rank the price changes to get the latest one                            |
-- -- | `LEFT JOIN`              | Include all products, even if no price exists before given date         |
-- -- | `COALESCE(..., 10)`      | Fallback to default price if none found                                 |


-- -- ```sql
-- -- ROW_NUMBER() OVER (
-- --     PARTITION BY product_id
-- --     ORDER BY change_date DESC
-- -- )
-- -- ```

-- -- This is a **window function** in SQL. Let's understand it line by line:

-- -- ---

-- -- #What is `ROW_NUMBER()`?

-- -- - `ROW_NUMBER()` assigns a unique number to each row **within a group**.
-- -- - The numbering starts at `1`, and increases based on the order you specify.

-- -- ---

-- -- #What is `OVER (...)`?

-- -- The `OVER` clause defines **how** to apply the `ROW_NUMBER()` — like "within what group" and "in what order".

-- -- ---

-- -- Full Breakdown:

-- -- ### `PARTITION BY product_id`

-- -- - This **splits** the data into groups based on `product_id`.
-- -- - Each group is processed **independently**.
-- -- - So every product gets its **own sequence of row numbers**.

-- -- Think of it like applying `ROW_NUMBER()` separately for each product.

-- -- ---

-- -- ### `ORDER BY change_date DESC`

-- -- - Within each `product_id` group, the rows are sorted by `change_date` in **descending** order (latest date first).
-- -- - So, the **most recent change** gets `ROW_NUMBER = 1`.

-- -- ---

-- -- #Example

-- -- Imagine this data:

-- -- | product_id | new_price | change_date |
-- -- |------------|-----------|-------------|
-- -- | 1          | 20        | 2019-08-14  |
-- -- | 1          | 30        | 2019-08-15  |
-- -- | 1          | 35        | 2019-08-16  |
-- -- | 2          | 50        | 2019-08-14  |

-- -- When we apply:

-- -- ```sql
-- -- ROW_NUMBER() OVER (
-- --     PARTITION BY product_id
-- --     ORDER BY change_date DESC
-- -- )
-- -- ```

-- -- We get:

-- -- | product_id | change_date | row_number |
-- -- |------------|-------------|------------|
-- -- | 1          | 2019-08-16  | 1          |
-- -- | 1          | 2019-08-15  | 2          |
-- -- | 1          | 2019-08-14  | 3          |
-- -- | 2          | 2019-08-14  | 1          |

-- -- ---

-- -- #Result

-- -- This lets you easily **pick the most recent row per product**, because it’s the one with `ROW_NUMBER = 1`.

-- -- _______________________________________________________________________________________________
-- -- _________________________________________________________________________________________________

-- -- Let's focus on this specific part:

-- -- ```sql
-- -- LEFT JOIN ranked_prices r 
-- --   ON p.product_id = r.product_id 
-- --   AND r.rn = 1
-- -- ```

-- -- ---

-- -- What's happening here?

-- -- This is joining a table of **all unique products** (`p`) with the **ranked prices** (`r`) — but it's **only picking the most recent price change for each product**, before or on `'2019-08-16'`.

-- -- ---

-- -- #Why `r.rn = 1`?

-- -- In the **CTE (`WITH ranked_prices AS (...)`)**, we created a `ROW_NUMBER()` for each product, ordered by `change_date DESC`.  
-- -- So:

-- -- - `r.rn = 1` means: the **latest price change** (i.e., most recent `change_date`) **before or on 2019-08-16** for that `product_id`.

-- -- ---

-- -- Example:

-- -- Imagine `ranked_prices` looks like this for product 1:

-- -- | product_id | new_price | change_date | rn |
-- -- |------------|-----------|-------------|----|
-- -- | 1          | 35        | 2019-08-16  | 1  ← most recent
-- -- | 1          | 30        | 2019-08-15  | 2
-- -- | 1          | 20        | 2019-08-14  | 3

-- -- By doing:

-- -- ```sql
-- -- LEFT JOIN ... ON p.product_id = r.product_id AND r.rn = 1
-- -- ```

-- -- We **only join** the most recent row (i.e., `rn = 1`) — this gives us **only one price per product**, and it's the latest one up to `'2019-08-16'`.

-- -- ---

-- -- #Why not just use `MAX(change_date)`?

-- -- Good question!

-- -- - `MAX()` works for getting the **latest date**, but we also need the **price (`new_price`)** **on that exact date**.
-- -- - So `ROW_NUMBER()` + `r.rn = 1` gives us **both the date and the price** in one row.

-- -- ---

-- -- #Final Result:

-- -- You get each product with its correct price as of 2019-08-16.  
-- -- If there was **no price change** for a product before that date, `r` will be `NULL`, and:

-- -- ```sql
-- -- COALESCE(r.new_price, 10)
-- -- ```

-- -- will default to **10** (the assumed starting price).

-- -- ________________________________________________________________________________________

-- -- SUMMARY

-- -- # **CTE: `ranked_prices`**

-- -- ```sql
-- -- WITH ranked_prices AS (
-- --     SELECT *,
-- --            ROW_NUMBER() OVER (
-- --                PARTITION BY product_id
-- --                ORDER BY change_date DESC
-- --            ) AS rn
-- --     FROM Products
-- --     WHERE change_date <= '2019-08-16'
-- -- )
-- -- ```

-- -**Purpose:**  
-- -- To pick the **most recent price change (before or on 2019-08-16)** for each product.

-- -- - `ROW_NUMBER()` gives a ranking for each product’s price history.
-- -- - `rn = 1` means: latest price (before or on that date).

-- -- ---

-- -- ##**Main Query**

-- -- ```sql
-- -- SELECT
-- --     p.product_id,
-- --     COALESCE(r.new_price, 10) AS price
-- -- FROM
-- --     (SELECT DISTINCT product_id FROM Products) p
-- -- LEFT JOIN ranked_prices r
-- --     ON p.product_id = r.product_id AND r.rn = 1
-- -- ```

-- --**Purpose:**  
-- -- To return **every product** and its **price on 2019-08-16**:

-- -- - If a recent price exists → use it (`r.new_price`)
-- -- - If no price change before 2019-08-16 → default to `10` using `COALESCE`.

-- -- ---

-- -- Let’s walk through how the data looks **after the CTE** and **after the main query**, using your example:

-- ---

-- -- #**Original `Products` Table**

-- -- | product_id | new_price | change_date |
-- -- |------------|-----------|-------------|
-- -- | 1          | 20        | 2019-08-14  |
-- -- | 2          | 50        | 2019-08-14  |
-- -- | 1          | 30        | 2019-08-15  |
-- -- | 1          | 35        | 2019-08-16  |
-- -- | 2          | 65        | 2019-08-17  |
-- -- | 3          | 20        | 2019-08-18  |

-- -- ---

-- -- ##**After the CTE (`ranked_prices`)**  
-- -- Only includes prices **on or before `2019-08-16`**, and adds a row number `rn` to find the latest price per product.

-- -- | product_id | new_price | change_date | rn |
-- -- |------------|-----------|-------------|----|
-- -- | 1          | 35        | 2019-08-16  | 1  |
-- -- | 1          | 30        | 2019-08-15  | 2  |
-- -- | 1          | 20        | 2019-08-14  | 3  |
-- -- | 2          | 50        | 2019-08-14  | 1  |

-- -- >Note: Product 2's newer price (65 on 2019-08-17) and Product 3's price (20 on 2019-08-18) are excluded from the CTE as they’re after 2019-08-16.

-- -- ---

-- -- #**After the Final Query**

-- -- - We select **each distinct product**.
-- -- - **Join** with the CTE to get their **latest price before or on 2019-08-16**.
-- -- - If a product doesn’t have a price by that date → use `10`.

-- -- | product_id | price |
-- -- |------------|-------|
-- -- | 1          | 35    | ← from `rn = 1` row
-- -- | 2          | 50    | ← from `rn = 1` row
-- -- | 3          | 10    | ← no price before 2019-08-16, so use default

-- -- ---

-- -- #Summary:
-- -- - **CTE = filter + rank**
-- -- - **Final query = match all products + get their most recent (rank 1) price or default**

-- -- #Summary:
-- -- - **CTE:** Find latest known price before or on 2019-08-16
-- - **Main Query:** Combine that info with all products & apply default where needed