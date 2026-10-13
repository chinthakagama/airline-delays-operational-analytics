-- AS’s daily cancellations in January. This will show whether they clustered within a particular period

SELECT
    fl_date,
    COUNT(*) AS scheduled_flights,

    COUNT(*) FILTER (
        WHERE cancelled = 1
    ) AS cancelled_flights,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE cancelled = 1)
        / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_pct

FROM airline.flights_reporting
WHERE op_unique_carrier = 'AS'
  AND fl_date >= DATE '2024-01-01'
  AND fl_date < DATE '2024-02-01'
GROUP BY fl_date
ORDER BY fl_date;

-- The daily rate peaked at 29.40% on 17 January. Rates fell towards month-end, 
-- although the final two days remained above the early-January level.
-- This establishes a disruption window; it does not establish the cause