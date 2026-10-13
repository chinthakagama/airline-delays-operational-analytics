-- dep_delay_new and arr_delay_new should equal the original delay with negative values replaced by zero. The del15 flags should identify delays of at least 15 minutes.


SELECT
    COUNT(*) FILTER (
        WHERE dep_delay IS NOT NULL
          AND dep_delay_new IS DISTINCT FROM
              GREATEST(dep_delay, 0)
    ) AS departure_minutes_mismatch,

    COUNT(*) FILTER (
        WHERE arr_delay IS NOT NULL
          AND arr_delay_new IS DISTINCT FROM
              GREATEST(arr_delay, 0)
    ) AS arrival_minutes_mismatch,

    COUNT(*) FILTER (
        WHERE dep_delay IS NOT NULL
          AND dep_del15 IS DISTINCT FROM
              CASE WHEN dep_delay >= 15 THEN 1 ELSE 0 END
    ) AS departure_flag_mismatch,

    COUNT(*) FILTER (
        WHERE arr_delay IS NOT NULL
          AND arr_del15 IS DISTINCT FROM
              CASE WHEN arr_delay >= 15 THEN 1 ELSE 0 END
    ) AS arrival_flag_mismatch
FROM airline.raw_flights;

-- (All four delay-consistency checks passed. The delay-minute fields and 15-minute flags agree with the original delay values.)