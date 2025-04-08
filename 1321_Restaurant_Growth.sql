# Write your MySQL query statement below
SELECT
    a.visited_on,
    SUM(b.amount) AS amount,
    ROUND(SUM(b.amount) / 7, 2) AS average_amount
FROM
(
    SELECT visited_on, SUM(amount) AS amount
    FROM Customer
    GROUP BY visited_on
) a
JOIN
(
    SELECT visited_on, SUM(amount) AS amount
    FROM Customer
    GROUP BY visited_on
) b
ON b.visited_on BETWEEN DATE_SUB(a.visited_on, INTERVAL 6 DAY) AND a.visited_on
GROUP BY a.visited_on
HAVING COUNT(*) = 7
ORDER BY a.visited_on

-- a.visited_on = the main date (the current day in the 7-day window)
-- This is the date we want to compute the 7-day moving average for.

-- b.visited_on = dates within the 7-day window ending at a.visited_on
-- These are the other rows we want to include in the average — from the same table, but for earlier days (including current day).

-- Example:
-- a.visited_on	b.visited_on	b.amount
-- 2019-01-07	    2019-01-01	       100
-- 2019-01-07	    2019-01-02	       110
-- 2019-01-07	    2019-01-03	       120
-- 2019-01-07	    2019-01-04	       130
-- 2019-01-07	    2019-01-05	       110
-- 2019-01-07	    2019-01-06	       140
-- 2019-01-07	    2019-01-07	       150

-- So here:
-- a.visited_on = '2019-01-07' (the target day)
-- b.visited_on = each of the 7 days from '2019-01-01' to '2019-01-07'
-- We take all b.amounts from the matching b.visited_ons and compute:
-- SUM(b.amount) = 860
-- ROUND(SUM(b.amount)/7, 2) = 122.86

-- Why Self Join?
-- This lets us simulate a 7-day rolling window in plain SQL by matching each day (a.visited_on) with its past 6 days in b

-- a: for the current day (the day you're calculating the 7-day average for)
-- b: for previous days + current day — i.e., the 7-day window ending on a.visited_on
-- ON b.visited_on BETWEEN DATE_SUB(a.visited_on, INTERVAL 6 DAY) AND a.visited_on
-- You're telling SQL:
-- → for each date a.visited_on,
-- → find all b.visited_on from 6 days before up to the same day (inclusive).

-- GROUP BY a.visited_on
-- We group the results based on each unique a.visited_on date.
-- This means: For each a.visited_on, gather all the rows from b that fall within the 7-day window ending on a.visited_on.
-- Example: If a.visited_on = '2019-01-07', then all b rows from '2019-01-01' to '2019-01-07' are grouped together.

-- HAVING COUNT(*) = 7
-- After grouping, we check how many rows are in the group.
-- We want exactly 7 rows, which means:
-- Only keep the dates where the full 7-day window has data (no missing days).
-- Why? Because if we try to calculate a 7-day moving average with fewer than 7 days, it won’t be accurate. This filter ensures we only include complete weeks.
-- Example: Let’s say the dataset starts on 2019-01-01. For a.visited_on = '2019-01-05', we would try to gather rows from '2018-12-30' to '2019-01-05' — but '2018-12-30' and '2018-12-31' don't exist. So that group would have less than 7 rows and be excluded.

-- ORDER BY a.visited_on
-- Finally, sort the results by the visited_on date (i.e., current date for the moving average).
-- This helps display the data in chronological order — which is useful for analysis or plotting.