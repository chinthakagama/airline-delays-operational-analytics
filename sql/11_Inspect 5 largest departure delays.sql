-- 2. Inspect the five largest departure delays
SELECT
    fl_date,
    op_unique_carrier,
    op_carrier_fl_num,
    origin,
    dest,
    dep_delay,
    arr_delay,
    cancelled,
    diverted,
    carrier_delay,
    weather_delay,
    nas_delay,
    security_delay,
    late_aircraft_delay
FROM airline.raw_flights
WHERE dep_delay IS NOT NULL
ORDER BY dep_delay DESC
LIMIT 5;