# Write your MySQL query statement below
-- SELECT
--     machine_id, ROUND(SUM(CASE WHEN activity_type='start' THEN -timestamp ELSE timestamp END) * 1.0
--                 / (SELECT COUNT(DISTINCT process_id)), 3) AS processing_time
-- FROM Activity
-- GROUP BY machine_id

-- machine_id	process_id	activity_type	timestamp	CASE WHEN Output
-- 0	            0	        start	       0.712	    -0.712
-- 0	            0	        end	           1.520	     1.520
-- 0	            1	        start	       3.140	    -3.140
-- 0	            1	        end	           4.120	     4.120
-- Now summing these values:
-- (−0.712)+1.520+(−3.140)+4.120=1.788

-- (SELECT COUNT(DISTINCT process_id))
-- Since process_id is 0 and 1, we have 2 unique processes.
-- So, the division:
-- 1.788/2=0.894

-- _______________________________________________________________________________________________

SELECT a.machine_id,
    ROUND(AVG(b.timestamp - a.timestamp), 3) AS processing_time
FROM Activity a, Activity b
WHERE
    a.machine_id = b.machine_id
AND
    a.process_id = b.process_id
AND
    a.activity_type = 'start' AND b.activity_type = 'end'
GROUP BY machine_id