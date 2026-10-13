-- Next, calculate each cause’s monthly percentage contribution
WITH cause_totals AS (
    SELECT
        year,
        month,
        SUM(carrier_delay) AS carrier,
        SUM(weather_delay) AS weather,
        SUM(nas_delay) AS nas,
        SUM(security_delay) AS security,
        SUM(late_aircraft_delay) AS late_aircraft,
        SUM(arr_delay) AS total_delay
    FROM airline.flights_reporting
    WHERE arrival_delay_eligible
      AND arr_delay >= 15
    GROUP BY year, month
)
SELECT
    t.year,
    t.month,
    c.delay_cause,
    c.delay_minutes,
    ROUND(
        (100.0 * c.delay_minutes
        / NULLIF(t.total_delay, 0))::numeric,
        2
    ) AS share_of_delay_minutes_pct
FROM cause_totals AS t
CROSS JOIN LATERAL (
    VALUES
        ('Carrier', t.carrier),
        ('Weather', t.weather),
        ('NAS', t.nas),
        ('Security', t.security),
        ('Late aircraft', t.late_aircraft)
) AS c(delay_cause, delay_minutes)
ORDER BY t.year, t.month, c.delay_minutes DESC;
-- This introduces CROSS JOIN LATERAL: 
-- it turns the five cause columns into five rows per month—a useful format for Power BI.
-- Interpret the percentages as shares of recorded delay minutes, not shares of flights. 
-- They cover eligible arrivals delayed by at least 15 minutes and exclude cancellations and diversions.