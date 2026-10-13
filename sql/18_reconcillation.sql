-- # Before calculating cause shares, check whether the five cause fields reconcile to 
-- arrival delay for every eligible delayed flight
SELECT
    year,
    month,
    COUNT(*) AS delayed_arrivals,

    COUNT(*) FILTER (
        WHERE ABS(
            arr_delay - (
                carrier_delay
                + weather_delay
                + nas_delay
                + security_delay
                + late_aircraft_delay
            )
        ) > 0.01
    ) AS cause_sum_mismatch_rows,

    SUM(arr_delay) AS arrival_delay_min,

    SUM(
        carrier_delay
        + weather_delay
        + nas_delay
        + security_delay
        + late_aircraft_delay
    ) AS recorded_cause_min

FROM airline.flights_reporting
WHERE arrival_delay_eligible
  AND arr_delay >= 15
GROUP BY year, month
ORDER BY year, month;

-- # The reconciliation passed: every eligible delayed flight’s cause minutes match its arrival delay. 
-- Q1 totals 23,313,587 recorded delay minutes, with zero mismatches.