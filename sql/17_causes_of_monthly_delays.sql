-- ecorded delay causes monthly breakdown.
-- Run this monthly breakdown
SELECT
    year,
    month,

    COUNT(*) FILTER (
        WHERE arrival_delay_eligible
          AND arr_delay >= 15
    ) AS delayed_arrivals,

    COUNT(*) FILTER (
        WHERE arrival_delay_eligible
          AND arr_delay >= 15
          AND (
              carrier_delay IS NULL
              OR weather_delay IS NULL
              OR nas_delay IS NULL
              OR security_delay IS NULL
              OR late_aircraft_delay IS NULL
          )
    ) AS delayed_rows_with_missing_causes,

    SUM(carrier_delay) AS carrier_delay_min,
    SUM(weather_delay) AS weather_delay_min,
    SUM(nas_delay) AS nas_delay_min,
    SUM(security_delay) AS security_delay_min,
    SUM(late_aircraft_delay) AS late_aircraft_delay_min

FROM airline.flights_reporting
WHERE arrival_delay_eligible
  AND arr_delay >= 15
GROUP BY year, month
ORDER BY year, month;

-- January’s directly recorded weather-delay minutes were much higher. That does not establish weather’s total impact: 
-- these figures describe recorded categories, and cancellation causes are still separate.