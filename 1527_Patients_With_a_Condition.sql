# Write your MySQL query statement below
SELECT *
FROM Patients
WHERE conditions LIKE ('DIAB1%') OR conditions LIKE ('% DIAB1%')

-- usually % or _ is used with LIKE:
-- % for unlimited characters
-- _ for 1 character