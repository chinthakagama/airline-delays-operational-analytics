# Airline Delays Operational Analytics

An end-to-end portfolio project analysing **1,658,259 flight records from Q1 2024** using Python, PostgreSQL and Power BI.

The project examines flight reliability, identifies periods and locations of disruption, and compares recorded delay causes. It preserves cancelled and diverted flights, validates the data before aggregation, and uses explicit eligibility rules for arrival-delay metrics.

## Business problem

Operational stakeholders need to understand when reliability deteriorates, which carriers and routes warrant investigation, and how frequently and severely passengers experience disruption. Counts alone can be misleading: high-volume carriers can have many delayed flights while maintaining a comparatively low delay rate.

The analysis answers:

- How did cancellations, arrival-delay frequency and delay severity change across January, February and March?
- Which carriers stand out on different reliability measures?
- Was AS's cancellation problem concentrated in a particular period?
- Which recorded categories contributed to B6's delays, and where did its March delay burden accumulate?

## Tools and workflow

| Tool | Role |
|---|---|
| Python and Jupyter | File ingestion and PostgreSQL connection |
| SQLAlchemy and psycopg2 | Database connectivity |
| PostgreSQL and pgAdmin 4 | Profiling, validation, reporting view and operational analysis |
| Power Query | Type checking and importing the reporting view |
| DAX | Filter-aware counts, rates, averages and cause-minute measures |
| Power BI Desktop | Interactive report and airline slicer |

The workflow follows **extract, load and transform**: monthly files were loaded into `airline.raw_flights`, profiled in SQL, and exposed through `airline.flights_reporting`. Power BI imported the view as `Flights`.

## Dataset and scope

Source: [Bureau of Transportation Statistics Reporting Carrier On-Time Performance](https://www.transtats.bts.gov/TableInfo.asp?QO_fu146_anzr=b0-gvzr&gnoyr_VQ=FGJ).

The official flight-level dataset provides dates, operating/reporting carrier identifiers, airports, scheduled and actual performance, cancellation and diversion flags, distance, durations and recorded delay causes. Aviation provides a relevant setting for combining operational judgement, quality assurance and analytics.

| Month | Records | Verified date coverage |
|---|---:|---|
| January | 547,271 | 1–31 January 2024 |
| February | 519,221 | 1–29 February 2024 |
| March | 591,767 | 1–31 March 2024 |
| **Total** | **1,658,259** | **Q1 2024** |

This report describes the included reporting-carrier records. It does not represent every aviation operation or establish annual seasonality.

## Results at a glance

| Q1 metric | Result |
|---|---:|
| Scheduled flights in the dataset | 1,658,259 |
| Completed flights and eligible arrivals | 1,626,052 |
| Cancelled flights | 28,511 |
| Diverted flights | 3,696 |
| Cancellation rate | 1.72% |
| Diversion rate | 0.22% |
| Arrivals delayed by at least 15 minutes | 330,478 |
| Arrival-delay rate | 20.32% |
| Average delay among delayed arrivals | 70.55 minutes |
| Recorded delay minutes among eligible delayed arrivals | 23,313,587 |

**The 70.55-minute average applies only to eligible arrivals delayed by at least 15 minutes. It is not an average across all flights.**

## Data quality decisions

### Import reconciliation

Monthly counts and date ranges matched the expected input totals. A guard stopped another import when the raw table already contained 1,658,259 rows, preventing an accidental repeated append. This guard is not a complete mechanism for recovering a partially failed import.

### Missing values

Essential date, carrier, origin, destination and status fields had no missing values. Delay missingness was profiled by flight status.

| Flight status | Records | Missing departure delay | Missing arrival delay | Missing actual duration |
|---|---:|---:|---:|---:|
| Completed | 1,626,052 | 0 | 0 | 0 |
| Diverted | 3,696 | 0 | 3,696 | 3,696 |
| Cancelled | 28,511 | 27,679 | 28,511 | 28,511 |

Missing delays were **not replaced with zero**. A cancelled flight has no eligible arrival outcome; treating its missing arrival delay as zero would imply punctual arrival. Cancelled and diverted records were retained for reliability measures.

There were 832 cancelled records with departure-delay values. These were retained because their presence alone did not establish an error.

Two cancelled records had unusable scheduled durations:

- NK 2331, BWI → SJU, 11 February: missing duration.
- WN 336, LAS → RNO, 27 March: −160 minutes.

Both flights remain in cancellation counts. Their scheduled durations become `NULL` in `valid_scheduled_duration`.

### Duplicates and consistency

- Whole-row comparison found zero exact duplicates; no deduplication was applied.
- Nonnegative delay fields matched signed delays with negatives set to zero.
- Departure and arrival 15-minute flags matched their underlying delays.
- All eligible delayed arrivals had complete recorded cause fields.
- The sum of five cause fields matched arrival delay for every eligible delayed record, using a 0.01-minute comparison tolerance.

Exact duplicate validation does not establish that a candidate business key is universally unique.

### Outliers

Extreme delays were investigated and retained. The largest departure delay was 3,360 minutes; its corresponding arrival delay was 3,359 minutes. The five largest departure-delay records had internally reconciling arrival-delay causes.

Internal consistency supports retention but does not independently prove accuracy. No blanket trimming, winsorisation or IQR deletion was applied. Negative signed delays were preserved because they represent early departures or arrivals.

## Reporting view and derived fields

`airline.flights_reporting` preserves raw columns and adds:

| Field | Rule |
|---|---|
| `flight_status` | Cancelled first, then Diverted, otherwise Completed |
| `arrival_delay_eligible` | Not cancelled, not diverted, and arrival delay present |
| `scheduled_duration_issue` | Scheduled duration missing or nonpositive |
| `valid_scheduled_duration` | Positive scheduled duration; otherwise `NULL` |

```sql
CREATE OR REPLACE VIEW airline.flights_reporting AS
SELECT
    f.*,
    CASE
        WHEN cancelled = 1 THEN 'Cancelled'
        WHEN diverted = 1 THEN 'Diverted'
        ELSE 'Completed'
    END AS flight_status,
    CASE
        WHEN cancelled = 0 AND diverted = 0
         AND arr_delay IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS arrival_delay_eligible,
    CASE
        WHEN crs_elapsed_time IS NULL OR crs_elapsed_time <= 0
        THEN TRUE ELSE FALSE
    END AS scheduled_duration_issue,
    CASE
        WHEN crs_elapsed_time > 0 THEN crs_elapsed_time
        ELSE NULL
    END AS valid_scheduled_duration
FROM airline.raw_flights AS f;
```

A view stores the query definition rather than a separate cleaned dataset. Power BI Import mode requires a refresh to receive database changes.

Field selection was driven by reporting needs, not predictive-model feature selection. A `Month Name` calculated column was added and sorted by numeric `month` for chronological labels. No machine-learning model or automated feature-importance process was implemented.

## SQL investigation

The analysis progressed from broad validation to focused investigation:

1. Retrieve records and reconcile monthly counts and dates.
2. Profile identifiers, status flags and missing values.
3. Check exact duplicates, numerical violations and delay-field consistency.
4. Create and validate the reporting view.
5. Aggregate overall and monthly KPIs using conditional counts and explicit denominators.
6. Reconcile delay causes at record and monthly levels.
7. Calculate cause shares using a CTE and `CROSS JOIN LATERAL ... VALUES`.
8. Compare carriers and inspect AS and B6 monthly patterns.
9. Locate AS's daily disruption window and compare cancellation codes using period classification and a window-function denominator.
10. Drill down to departure airports and directional routes.
11. Locate B6's March destination burden and JFK inbound routes.
12. Compare recorded cause mixes for ATL → JFK and SJU → JFK.

SQL techniques included `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, `GROUP BY`, `HAVING`, aggregate `FILTER`, `CASE`, `NULLIF`, `COALESCE`, `IS DISTINCT FROM`, CTEs, window functions and lateral row construction. The project report contains query examples and explanations of their analytical purpose.

## DAX measures and metric definitions

| Metric | Numerator or calculation | Denominator or population |
|---|---|---|
| Cancellation rate | Cancelled flights | All included scheduled flights |
| Diversion rate | Diverted flights | All included scheduled flights |
| Arrival-delay rate | Eligible arrivals with `arr_delay >= 15` | All eligible arrivals |
| Average delayed-arrival severity | Mean signed arrival delay | Eligible arrivals delayed by at least 15 minutes |
| Recorded cause share | Minutes assigned to one cause | Total recorded cause minutes among eligible delayed arrivals |

Core measures:

```dax
Scheduled Flights = COUNTROWS(Flights)

Cancelled Flights =
CALCULATE([Scheduled Flights], Flights[cancelled] = 1)

Cancellation Rate =
DIVIDE([Cancelled Flights], [Scheduled Flights])

Eligible Arrivals =
CALCULATE(
    COUNTROWS(Flights),
    Flights[arrival_delay_eligible] = TRUE()
)

Delayed Arrivals =
CALCULATE(
    COUNTROWS(Flights),
    Flights[arrival_delay_eligible] = TRUE(),
    Flights[arr_delay] >= 15
)

Arrival Delay Rate =
DIVIDE([Delayed Arrivals], [Eligible Arrivals])

Avg Delay Among Delayed Arrivals =
CALCULATE(
    AVERAGE(Flights[arr_delay]),
    Flights[arrival_delay_eligible] = TRUE(),
    Flights[arr_delay] >= 15
)

Carrier Delay Minutes =
CALCULATE(
    SUM(Flights[carrier_delay]),
    Flights[arrival_delay_eligible] = TRUE(),
    Flights[arr_delay] >= 15
)
```

The cause measure pattern also applies to weather, NAS, security and late-aircraft fields. Each formula is created as a separate measure. Rate measures are formatted as percentages without multiplying by 100. Ratios are recalculated from filtered counts rather than by averaging subgroup percentages.

## Dashboard

The Operational Overview page includes:

- Seven KPI cards for volume, cancellations, eligibility, delayed arrivals, rates and delayed-arrival severity.
- Monthly arrival-delay and cancellation charts.
- An airline comparison using arrival-delay rate.
- A donut showing arrival-delay minutes by recorded cause for delays of at least 15 minutes.
- An airline slicer for interactive exploration.

Unfiltered values visible in reviewed screenshots matched the SQL results. A B6 filter provides these validation benchmarks: 60,380 scheduled flights, 910 cancellations, 59,285 eligible arrivals, 16,649 delayed arrivals, 28.08% arrival-delay rate and 79.20-minute mean among delayed arrivals.

The donut represents **shares of delay minutes, not shares of flights**. NAS means National Airspace System and includes broader operational conditions than air traffic control alone.

## Key findings

### January was the weakest month

| Metric | January | February | March |
|---|---:|---:|---:|
| Cancellation rate | 3.73% | 0.58% | 0.87% |
| Arrival-delay rate | 24.06% | 15.92% | 20.85% |
| Average among delayed arrivals | 75.46 min | 64.09 min | 69.80 min |

January accounted for 71.51% of Q1 cancellations. The arrival-delay rate fell 8.14 percentage points in February, then increased 4.93 points in March.

### AS cancellations were concentrated in January

AS's cancellation rate was 17.55% in January, compared with 0.81% in February and 0.73% in March.

During **6–29 January**, 3,054 of 13,493 AS flights were cancelled: **22.63%**. That window contained 97.92% of AS's January cancellations. Of those cancellations, **94.86% were recorded as carrier-related**.

Among directional routes with at least 50 scheduled flights in the window, SFO → JFK had a 64.71% cancellation rate. Both directions combined had 58 cancellations out of 103 flights, or 56.31%, all carrier-coded.

### B6 deteriorated in March

B6's March arrival-delay rate was **30.42%**, with delayed arrivals averaging **85.65 minutes** late. Carrier and late-aircraft categories accounted for **80.73%** of its recorded March delay minutes.

JFK accumulated 98,360 B6 arrival-delay minutes, representing 17.82% of B6's March total. Further inspection identified:

| March route | Delayed / eligible arrivals | Average among delayed arrivals | Largest recorded category |
|---|---:|---:|---|
| SJU → JFK | 67 / 173 | 139.88 min | Carrier: 47.55% |
| ATL → JFK | 30 / 62 | 172.83 min | Late aircraft: 54.14% |

These results locate operational exposure. They do not establish where a delay originated or prove a specific underlying failure.

## Recommendations

- Review AS's 6–29 January disruption against incident logs, aircraft availability, maintenance and crew records before selecting corrective action.
- Investigate B6's March rotations and recovery processes, focusing on JFK inbound exposure and the SJU and ATL routes highlighted by burden and severity.
- Monitor counts, rates and severity together; a single ranking cannot capture reliability.
- Extend the period and compare similar routes, airports and schedules before attributing carrier differences to management performance.
- Add calendar, carrier and airport dimensions, median and upper-percentile delay measures, and reusable import manifests and quality checks.

These are investigation priorities, not measured interventions or demonstrated cost savings.

## Limitations

- Three months cannot establish annual seasonality or long-term performance.
- Carrier comparisons are not adjusted for route mix, airport exposure or schedules.
- Recorded cause categories are broad; weather can affect categories beyond the dedicated weather field.
- Internally consistent extreme records are not independently verified.
- Volume thresholds are screening choices, not statistical significance tests.
- Exact duplicate checks do not establish business-key uniqueness.
- The project is descriptive; no predictive model or causal inference was implemented.

## Reproducing and reviewing the project

1. Obtain the Q1 2024 monthly data from the BTS source and retain source filenames, selected fields and extraction metadata.
2. Use the ingestion notebook/script to load the PostgreSQL raw table. Supply credentials locally rather than committing them.
3. Run quality checks and confirm the monthly counts above.
4. Create `airline.flights_reporting` and execute the KPI and investigation queries.
5. Open the Power BI report, configure the local PostgreSQL connection and refresh the imported `Flights` table.
6. Compare unfiltered and carrier-filtered results with the documented benchmarks.

The completed local workflow used the `airline_delays` database at `localhost:5432`. Reproduction depends on publishing the ingestion code, schema and SQL scripts alongside this README; this document alone does not recreate the database.

### Suggested repository organisation

```text
airline_delays_project/
├── README.md
├── data/
│   └── README.md
├── python/       # ingestion notebook or script
├── sql/          # schema, quality checks, view and analysis
├── dashboard/
│   ├── Airline_Operational_Performance_Q1_2024.pbix
│   └── operational_overview.png
└── docs/
    └── Airline_Operational_Performance_Q1_2024_Report.docx
```

This layout is a packaging guide. Add the actual local files before publishing. Keep large raw datasets outside the repository and document their download process. Add a clean screenshot of the report canvas to the dashboard folder.

## Sources

- [BTS Reporting Carrier On-Time Performance dataset](https://www.transtats.bts.gov/TableInfo.asp?QO_fu146_anzr=b0-gvzr&gnoyr_VQ=FGJ)
- [BTS explanation of delay and cancellation categories](https://www.bts.gov/topics/airlines-and-airports/understanding-reporting-causes-flight-delays-and-cancellations)
- [BTS field descriptions and downloads](https://www.transtats.bts.gov/DL_SelectFields.aspx?QO_fu146_anzr=&gnoyr_VQ=FGJ)

Project results derive from the executed SQL outputs and dashboard checks documented during development. Public sources establish dataset definitions; they do not independently reproduce the local results.
