-- Next, locate B6’s March arrival-delay burden by destination airport
SELECT
    dest AS arrival_airport,

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
  AND fl_date >= DATE '2024-03-01'
  AND fl_date < DATE '2024-04-01'
GROUP BY dest
HAVING COUNT(*) FILTER (
    WHERE arrival_delay_eligible
) >= 100
ORDER BY delayed_arrival_minutes DESC,
         dest
LIMIT 10;