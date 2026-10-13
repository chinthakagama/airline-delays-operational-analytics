-- As have enough detail on AS , let's return to B6’s persistent arrival delays, 
-- starting with its recorded cause mix by month
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
    WHERE op_unique_carrier = 'B6'
      AND arrival_delay_eligible
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

-- B6’s recorded delays were dominated by carrier and late-aircraft categories in every month. 
-- Together, they contributed 76.39% in January, 82.33% in February and 80.73% in March
-- March’s deterioration involved increases in both carrier and late-aircraft minutes. 
-- Late aircraft became the largest category, but its share rose only 0.95 percentage points from February. 
-- The absolute minutes tell a stronger story than the share alone.
-- These totals reflect flight volume, delay frequency and delay severity together. 
-- The earlier results already show March worsened on both frequency (30.42%) and severity (85.65 minutes among delayed arrivals).