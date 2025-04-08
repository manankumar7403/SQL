# Write your MySQL query statement below
WITH FirstLogin AS(
    SELECT player_id, MIN(event_date) AS first_login_date FROM Activity GROUP BY player_id
)
SELECT ROUND(COUNT(DISTINCT A.player_id) / COUNT(DISTINCT F.player_id), 2) AS fraction
FROM FirstLogin F
LEFT JOIN Activity A ON F.player_id = A.player_id AND A.event_date = DATE_ADD(F.first_login_date, INTERVAL 1 DAY)

-- WITH FirstLogin AS ...
-- It is used to create a CTE(Common Table Expression) -> acts as a temporary table that we can use with the main query
-- It is used to find each player's first login date
-- LEFT JOIN with Activity table is used to check if the player logged in on the next day.
-- DATE_ADD(F.first_login_date, INTERVAL 1 DAY) adds 1 day to the first login date.
-- COUNT(DISTINCT A.player_id) -> counts the number of players who logged in again the next day.
-- COUNT(DISTINCT F.player_id) -> Counts all unique players (from FirstLogin CTE)

-- Basically,
-- F.player_id = A.player_id ensures we are looking at the login records for the same player.
-- A.event_date = DATE_ADD(F.first_login_date, INTERVAL 1 DAY) filters the records to include only those logins
-- that happened exactly the day after the first login.