SELECT
    cancelled,
    diverted,
    COUNT(*) AS flight_count
FROM airline.raw_flights
GROUP BY cancelled, diverted
ORDER BY cancelled, diverted;