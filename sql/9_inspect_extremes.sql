SELECT
    MIN(dep_delay) AS min_departure_delay,
    MAX(dep_delay) AS max_departure_delay,
    MIN(arr_delay) AS min_arrival_delay,
    MAX(arr_delay) AS max_arrival_delay,
    MIN(distance) AS min_distance,
    MAX(distance) AS max_distance,
    MIN(actual_elapsed_time) AS min_actual_duration,
    MAX(actual_elapsed_time) AS max_actual_duration,
    MIN(air_time) AS min_air_time,
    MAX(air_time) AS max_air_time
FROM airline.raw_flights;

-- -- delay extremes are:
-- - Departure: 96 minutes early to 3,360 minutes late (56 hours).
-- - Arrival: 117 minutes early to 3,359 minutes late.