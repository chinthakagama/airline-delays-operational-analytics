SELECT
    year,
    month,
    COUNT(*) AS flight_count,
    MIN(fl_date) AS first_date,
    MAX(fl_date) AS last_date
FROM airline.raw_flights
GROUP BY year, month
ORDER BY year, month;