 -- 1. Inspect the scheduled-duration anomaly

SELECT
    fl_date,
    op_unique_carrier,
    op_carrier_fl_num,
    origin,
    dest,
    crs_dep_time,
    crs_arr_time,
    crs_elapsed_time,
    actual_elapsed_time,
    cancelled,
    diverted
FROM airline.raw_flights
WHERE crs_elapsed_time <= 0;