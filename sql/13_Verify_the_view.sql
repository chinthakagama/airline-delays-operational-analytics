-- # Verify the view
-- Here, “Completed” means neither cancelled nor diverted. The separate eligibility flag defines which flights enter our arrival-delay metrics.

SELECT
    flight_status,
    COUNT(*) AS flight_count,
    COUNT(*) FILTER (
        WHERE arrival_delay_eligible
    ) AS arrival_delay_eligible_count,
    COUNT(*) FILTER (
        WHERE scheduled_duration_issue
    ) AS scheduled_duration_issue_count
FROM airline.flights_reporting
GROUP BY flight_status
ORDER BY flight_status;




-- This view removes no rows. It gives us explicit rules for calculating metrics without silently discarding cancellations or unusual flights.