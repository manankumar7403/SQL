# Write your MySQL query statement below
SELECT *
FROM Users
WHERE mail REGEXP '^[A-Za-z][A-Za-z0-9_\.\-]*@leetcode[.]com$'

-- ^ -> start of string
-- [A-Za-z] -> first letter can be capital or small

-- In regular expressions, the dot . has a special meaning:
-- . means "any single character" (like a, 1, #, etc.).
-- So, if you write REGEXP '@leetcode.com'
-- This would match @leetcodeXcom, @leetcode1com, @leetcode_com
-- How to match a real, literal dot (like in .com)?
-- There are two main ways to say “this is an actual dot, not a wildcard”:
-- Pattern	Meaning
-- \\.	A literal dot. Escaped with backslash.
-- [.]	Character class containing only a dot.
-- \\.	Escaped . (dot). Dot is special in regex, so needs to be escaped to mean a literal period.
-- \\-	Escaped - (hyphen). Hyphen can be used for a range in brackets (like A-Z), so if you want a literal -, you either put it at the end of the character class ([-]) or escape it with \\-.