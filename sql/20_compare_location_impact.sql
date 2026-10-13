-- compare airlines to locate where reliability was weakest.
SELECT
    op_unique_carrier AS carrier_code,
    COUNT(*) AS scheduled_flights,

    COUNT(*) FILTER (
        WHERE arrival_delay_eligible
    ) AS eligible_arrivals,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE cancelled = 1)
        / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_pct,

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
GROUP BY op_unique_carrier
ORDER BY arrival_delay_rate_pct DESC NULLS LAST;

-- However, airlines operate different routes, airports and schedules.
-- Different airlines stand out on different measures—there is no single “worst airline” in these results.
-- WN also had the largest flight volume, so its delayed-flight count alone is not evidence of the weakest reliability.