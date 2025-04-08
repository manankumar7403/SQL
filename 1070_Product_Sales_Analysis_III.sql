# Write your MySQL query statement below
SELECT s.product_id, s.year AS first_year, s.quantity, s.price
FROM Sales s
JOIN(
    SELECT product_id, MIN(year) as first_year FROM Sales GROUP BY product_id
)
first_year_table ON s.product_id = first_year_table.product_id AND s.year = first_year_table.first_year

-- first_year_table is the name of the subquery creating temporary table that finds the first year a product was sold.
-- JOIN is combining the sales table(containing all sales records) and the first_year_table subquery(which finds the first year a product was sold). It basically matches each product in Sales with its first year from first_year_table.
-- first_year_table makes the query faster by computing MIN(year) only once, ensures that we get the correct
-- quantity and price for that year, avoids incorrect GROUP BY mistakes that might pick random values.

-- The thing is if we directly choose first_year as MIN(year) then that is correct but quantity and price are not based on it, so they are not properly selected.
-- SQL will pick random values for quantity and price(incorrect values).
-- We first compute MIN(year) once for each product then we JOIN to get the correct quantity and price, avoiding extra calculations and possibly TLE.