# Write your MySQL query statement below
(
    SELECT u.name AS results
    FROM MovieRating mr
    JOIN Users u ON mr.user_id = u.user_id
    GROUP BY u.user_id, u.name
    ORDER BY COUNT(*) DESC, u.name
    LIMIT 1
)
UNION ALL
(
    SELECT m.title AS results
    FROM MovieRating mr
    JOIN Movies m ON mr.movie_id = m.movie_id
    WHERE mr.created_at BETWEEN '2020-02-01' AND '2020-02-29'
    GROUP BY mr.movie_id, m.title
    ORDER BY AVG(mr.rating) DESC, m.title
    LIMIT 1
)

-- Using UNION ALL instead of UNION as one of the test cases has user name and movie name, both = 'Rebecca',
-- UNION removes the duplicate rows, UNION ALL keeps all the results including duplicates