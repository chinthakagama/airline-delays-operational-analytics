-- Check essential missing values

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE fl_date IS NULL) AS missing_date,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(op_unique_carrier), '') IS NULL
    ) AS missing_carrier,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(origin), '') IS NULL
    ) AS missing_origin,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(dest), '') IS NULL
    ) AS missing_destination,
    COUNT(*) FILTER (WHERE cancelled IS NULL) AS missing_cancelled,
    COUNT(*) FILTER (WHERE diverted IS NULL) AS missing_diverted
FROM airline.raw_flights;