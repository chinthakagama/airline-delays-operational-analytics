-- Next, check whether cancellations were concentrated on particular routes.
SELECT
    origin,
    dest,
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
    ) AS carrier_related_cancellations

FROM airline.flights_reporting
WHERE op_unique_carrier = 'AS'
  AND fl_date >= DATE '2024-01-06'
  AND fl_date < DATE '2024-01-30'
GROUP BY origin, dest
HAVING COUNT(*) >= 50
ORDER BY cancellation_rate_pct DESC,
         cancelled_flights DESC,
         origin,
         dest
LIMIT 10;

-- SFO → JFK had the highest cancellation rate among AS routes with at least 50 scheduled flights during 6–29 January: 64.71%.
-- Both directions of SFO ↔ JFK were heavily affected. Combined, 58 of 103 flights were cancelled—56.31%, all recorded as carrier-related.
-- Do not confuse the ranking with operational impact: SEA → MCO had more cancellations (34) than SFO → JFK (33), despite its lower rate of 39.08%. Also, the 50-flight threshold is a screening choice; it excludes smaller routes
