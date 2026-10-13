-- compare monthly, rates and delay severity, not just delayed-flight counts: 
-- a busier month can have more delayed flights while performing better proportionally.
SELECT
    year,
    month,
    COUNT(*) AS scheduled_flights,

    COUNT(*) FILTER (
        WHERE arrival_delay_eligible
    ) AS eligible_arrivals,

    COUNT(*) FILTER (
        WHERE cancelled = 1
    ) AS cancelled_flights,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE cancelled = 1)
        / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_pct,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE diverted = 1)
        / NULLIF(COUNT(*), 0),
        2
    ) AS diversion_rate_pct,

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
    ) AS avg_delay_among_delayed_arrivals_min

FROM airline.flights_reporting
GROUP BY year, month
ORDER BY year, month;