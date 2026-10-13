-- B6’s March flights arriving at JFK, grouped by departure airport
SELECT
    origin AS departure_airport,

    COUNT(*) FILTER (
        WHERE arrival_delay_eligible
    ) AS eligible_arrivals,

    COUNT(*) FILTER (
        WHERE arrival_delay_eligible AND arr_delay >= 15
    ) AS delayed_arrivals,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE arrival_delay_eligible AND arr_delay >= 15
        )
        / NULLIF(
            COUNT(*) FILTER (WHERE arrival_delay_eligible),
            0
        ),
        2
    ) AS arrival_delay_rate_pct,

    ROUND(
        (
            AVG(arr_delay) FILTER (
                WHERE arrival_delay_eligible AND arr_delay >= 15
            )
        )::numeric,
        2
    ) AS avg_delay_among_delayed_arrivals_min,

    SUM(arr_delay) FILTER (
        WHERE arrival_delay_eligible AND arr_delay >= 15
    ) AS delayed_arrival_minutes

FROM airline.flights_reporting
WHERE op_unique_carrier = 'B6'
  AND dest = 'JFK'
  AND fl_date >= DATE '2024-03-01'
  AND fl_date < DATE '2024-04-01'
GROUP BY origin
HAVING COUNT(*) FILTER (
    WHERE arrival_delay_eligible
) >= 30
ORDER BY delayed_arrival_minutes DESC,
         origin
LIMIT 10;
-- SJU → JFK contributed the most delay minutes in this selection, while ATL → JFK had the highest delay rate and longest average delay.
-- # Two useful distinctions:
-- - ATL → JFK: 30 of 62 arrivals were delayed, averaging almost 2 hours 53 minutes late among those delayed flights.
-- - SFO → JFK: a lower delay rate of 24.37%, but delayed arrivals averaged 145.28 minutes late. Less frequent delays can still be severe.