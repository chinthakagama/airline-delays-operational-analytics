-- Next, inspect the recorded cancellation codes for each period
WITH cancellations AS (
    SELECT
        CASE
            WHEN fl_date < DATE '2024-01-06' THEN '1–5 January'
            WHEN fl_date < DATE '2024-01-30' THEN '6–29 January'
            ELSE '30–31 January'
        END AS period,
        COALESCE(
            NULLIF(TRIM(cancellation_code), ''),
            'Missing'
        ) AS cancellation_reason_code
    FROM airline.flights_reporting
    WHERE op_unique_carrier = 'AS'
      AND fl_date >= DATE '2024-01-01'
      AND fl_date < DATE '2024-02-01'
      AND cancelled = 1
)
SELECT
    period,
    cancellation_reason_code,
    COUNT(*) AS cancelled_flights,
    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (PARTITION BY period),
        2
    ) AS share_of_period_cancellations_pct
FROM cancellations
GROUP BY period, cancellation_reason_code
ORDER BY
    CASE period
        WHEN '1–5 January' THEN 1
        WHEN '6–29 January' THEN 2
        ELSE 3
    END,
    cancelled_flights DESC;

-- The percentage denominator here is cancelled flights within each period, not all scheduled flights.
-- The disruption was dominated by cancellations recorded as air-carrier related. 
-- BTS defines A = Air Carrier and B = Weather
-- supported finding is:
-- AS’s cancellation rate increased from 0.88% during 1–5 January to 22.63% during 6–29 January. 
-- Within the disruption window, 94.86% of cancellations were classified as air-carrier related
-- Code A is a broad category; it does not identify the specific operational failure.