SELECT
    COUNT(*) AS scheduled_flights,

    COUNT(*) FILTER (
        WHERE flight_status = 'Completed'
    ) AS completed_flights,

    COUNT(*) FILTER (
        WHERE flight_status = 'Cancelled'
    ) AS cancelled_flights,

    COUNT(*) FILTER (
        WHERE flight_status = 'Diverted'
    ) AS diverted_flights,

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

FROM airline.flights_reporting;

-- The denominators matter:
-- - Cancellation and diversion rates: all flights in the dataset.
-- - Arrival-delay rate: only flights eligible for arrival-delay analysis.
-- - Average delay: only eligible arrivals delayed by at least 15 minutes.