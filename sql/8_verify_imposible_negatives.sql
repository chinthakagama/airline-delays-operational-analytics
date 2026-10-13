SELECT
    COUNT(*) FILTER (WHERE distance <= 0) AS nonpositive_distance,
    COUNT(*) FILTER (WHERE taxi_out < 0) AS negative_taxi_out,
    COUNT(*) FILTER (WHERE taxi_in < 0) AS negative_taxi_in,
    COUNT(*) FILTER (
        WHERE crs_elapsed_time <= 0
    ) AS nonpositive_scheduled_duration,
    COUNT(*) FILTER (
        WHERE actual_elapsed_time <= 0
    ) AS nonpositive_actual_duration,
    COUNT(*) FILTER (WHERE air_time < 0) AS negative_air_time,
    COUNT(*) FILTER (
        WHERE carrier_delay < 0
           OR weather_delay < 0
           OR nas_delay < 0
           OR security_delay < 0
           OR late_aircraft_delay < 0
    ) AS negative_delay_cause_rows
FROM airline.raw_flights;


-- (One record needs investigation: its scheduled duration is zero or negative.)