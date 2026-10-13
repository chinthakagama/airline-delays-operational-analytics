SELECT
    cancelled,
    diverted,
    COUNT(*) AS flight_count,
    COUNT(*) FILTER (
        WHERE dep_delay IS NULL
    ) AS missing_departure_delay,
    COUNT(*) FILTER (
        WHERE arr_delay IS NULL
    ) AS missing_arrival_delay,
    COUNT(*) FILTER (
        WHERE actual_elapsed_time IS NULL
    ) AS missing_elapsed_time
FROM airline.raw_flights
GROUP BY cancelled, diverted
ORDER BY cancelled, diverted;