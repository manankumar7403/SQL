# Write your MySQL query statement below
-- This is a concept of self join
-- we perform a self-join on the Weather table by giving it two different aliases:
-- w1: Represents the current day's record
-- w2: Represents the previous day's record

-- We are using Weather twice in the query.
-- We assign alias w1 to the first instance and alias w2 to the second instance.
-- This helps us compare the temperature of one date (w1) with its previous date (w2).

-- SELECT w1.id
-- FROM Weather w1, Weather w2
-- WHERE DATEDIFF(w1.recordDate, w2.recordDate) = 1
-- AND w1.temperature > w2.temperature;

SELECT w1.id
FROM Weather w1
JOIN Weather w2 ON DATEDIFF(w1.recordDate, w2.recordDate) = 1
WHERE w1.temperature > w2.temperature;