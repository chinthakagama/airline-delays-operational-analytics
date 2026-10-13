-- Check exact duplicate rows

SELECT
    COALESCE(SUM(copies - 1), 0) AS extra_duplicate_rows,
    COUNT(*) AS duplicate_groups
FROM (
    SELECT COUNT(*) AS copies
    FROM airline.raw_flights AS f
    GROUP BY f
    HAVING COUNT(*) > 1
) AS duplicates;