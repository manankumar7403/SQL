# Write your MySQL query statement below
SELECT customer_id FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM Product)

-- The total number of unique products in the Product table is counted.
-- We filter only those customers who have bought all these products.

-- COUNT(DISTINCT product_key) counts the number of distinct products that a specific customer has bought. It ensures that even if a customer buys the same product multiple times, it only counts unique products.

-- (SELECT COUNT(*) FROM Product) This counts the total number of products available in the Product table.
-- This tells us how many different products exist that need to be bought by a customer to be considered valid.

-- The HAVING Clause - The query only includes customers whose distinct product count matches the total product count in the Product table. If a customer has bought every product at least once, the two counts will be equal.