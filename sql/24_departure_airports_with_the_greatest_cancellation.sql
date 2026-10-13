-- Next, identify the departure airports with the greatest cancellation exposure during that window
SELECT
    origin AS departure_airport,
    COUNT(*) AS scheduled_flights,

    COUNT(*) FILTER (
        WHERE cancelled = 1
    ) AS cancelled_flights,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE cancelled = 1)
        / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_pct,

    COUNT(*) FILTER (
        WHERE cancelled = 1
          AND TRIM(cancellation_code) = 'A'
    ) AS carrier_related_cancellations,

    COUNT(*) FILTER (
        WHERE cancelled = 1
          AND TRIM(cancellation_code) = 'B'
    ) AS weather_cancellations

FROM airline.flights_reporting
WHERE op_unique_carrier = 'AS'
  AND fl_date >= DATE '2024-01-06'

 -- SEA had the largest cancellation count, while JFK had the highest cancellation rate among these ten airports.
  AND fl_date < DATE '2024-01-30'
GROUP BY origin
ORDER BY cancelled_flights DESC, scheduled_flights DESC
LIMIT 10;

-- SEA’s 19.62% cancellation rate was below AS’s 22.63% rate for the disruption window. Its large cancellation count partly reflects its much larger flight volume.
-- The disruption affected multiple departure airports, with carrier-related cancellations dominating each airport shown. That supports investigating a wider operational problem, but does not establish its specific cause.
-- One limitation: I selected these airports by cancellation count. JFK has the highest rate in this selection; I have not established that it had the highest rate across all airports.