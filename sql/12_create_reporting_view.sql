
-- # Now create a reporting view that adds status and quality flags while preserving the raw values
-- - Keep all six records. Flag the negative scheduled duration, and retain the extreme delays.
-- - The cancelled WN 336, LAS → RNO record has an invalid scheduled duration of −160 minutes. Keep it for cancellation counts, but exclude that duration from duration calculations.
-- - The five extreme delays have recorded cause minutes that sum to their arrival delays. That supports retaining them, although it does not independently prove their accuracy.

CREATE OR REPLACE VIEW airline.flights_reporting AS
SELECT
    f.*,

    CASE
        WHEN cancelled = 1 THEN 'Cancelled'
        WHEN diverted = 1 THEN 'Diverted'
        ELSE 'Completed'
    END AS flight_status,

    CASE
        WHEN cancelled = 0
         AND diverted = 0
         AND arr_delay IS NOT NULL
        THEN TRUE
        ELSE FALSE
    END AS arrival_delay_eligible,

    CASE
        WHEN crs_elapsed_time IS NULL
          OR crs_elapsed_time <= 0
        THEN TRUE
        ELSE FALSE
    END AS scheduled_duration_issue,

    CASE
        WHEN crs_elapsed_time > 0
        THEN crs_elapsed_time
        ELSE NULL
    END AS valid_scheduled_duration

FROM airline.raw_flights AS f;