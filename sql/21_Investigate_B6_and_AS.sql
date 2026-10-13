-- Let's investigate B6 and AS first: B6 for delay frequency, AS for cancellations. 
-- Compare their monthly performance to see whether the problem persisted or concentrated in January.
SELECT
    op_unique_carrier AS carrier_code,
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
WHERE op_unique_carrier IN ('B6', 'AS')
GROUP BY op_unique_carrier, year, month
ORDER BY op_unique_carrier, year, month;

-- AS recorded 3,119 of its 3,399 Q1 cancellations in January—91.76%. 
-- Its quarterly cancellation rate therefore hides a concentrated disruption.
-- B6’s delay rate exceeded the overall monthly rate in every month. 
-- March was its weakest month for both delay frequency and severity.