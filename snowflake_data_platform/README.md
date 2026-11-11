# Snowflake + dbt Data Engineering Platform

A hands-on Data Engineering project demonstrating the implementation of an analytical data platform using **Snowflake, dbt Core, SQL, incremental data processing, data quality tests, and Slowly Changing Dimensions (SCD Type 2)**.

The project processes customer, order, and payment datasets through multiple transformation layers to build reliable, analytics-ready data models.

## Tech Stack

- **Snowflake** — Cloud data warehouse
- **dbt Core** — SQL transformations, testing, and documentation
- **SQL** — Data modeling, deduplication, incremental processing, and aggregations
- **Python** — Local development environment and dbt tooling
- **Git / GitHub** — Version control and project documentation

## Architecture

```text
CSV Source Files
       |
       v
+-------------------+
| Snowflake RAW     |
| Source tables     |
+-------------------+
       |
       v
+-------------------+
| STAGING           |
| Cleaning          |
| Validation        |
+-------------------+
       |
       +------------------+
       |                  |
       v                  v
+----------------+  +------------------+
| CORE           |  | QUARANTINE       |
| Incremental    |  | Invalid records  |
| models         |  |                  |
+----------------+  +------------------+
       |
       v
+-------------------+
| MARTS             |
| Analytical models |
| Sales reporting   |
+-------------------+
```

## Data Domains

| Domain | Description |
|---|---|
| Customers | Customer records, validation, deduplication, and historical tracking |
| Orders | Order processing and analytical transformations |
| Payments | Payment processing and reconciliation |

Sample CSV files are organized under `data/customers/`, `data/orders/`, and `data/payments/`.

## Key Features

### Incremental Data Processing

Incremental dbt models use Snowflake `MERGE` operations to process new and updated records while reducing unnecessary reprocessing.

### Data Quality and Quarantine

The project includes validation rules and quarantine models to separate invalid records from trusted datasets.

dbt tests cover data integrity, uniqueness, nullability, reconciliation, and analytical consistency.

### Slowly Changing Dimensions (SCD Type 2)

dbt snapshots preserve historical changes in customer attributes, supporting historical analysis and tracking of customer state over time.

### Analytical Data Marts

The project includes analytical models for customer history, customer distribution by country, and sales-related reporting and reconciliation.

## Repository Structure

```text
.
├── data/
│   ├── customers/
│   ├── orders/
│   └── payments/
├── snowflake_data_platform/
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/
│   │   ├── core/
│   │   ├── quarantine/
│   │   └── marts/
│   ├── snapshots/
│   ├── tests/
│   └── macros/
├── .gitignore
└── README.md
```

## Running the Project

### Prerequisites

- A Snowflake account with the required database permissions
- Python and dbt Core
- The Snowflake adapter for dbt
- A configured local dbt profile

### Install Dependencies

```bash
python -m venv .venv
source .venv/bin/activate
pip install dbt-snowflake
```

### Run dbt

```bash
cd snowflake_data_platform

dbt debug
dbt parse
dbt build
```

Run data quality tests separately:

```bash
dbt test
```

Generate dbt documentation:

```bash
dbt docs generate
dbt docs serve
```

The source tables must be provisioned and populated in Snowflake before running the transformations.

## Engineering Concepts Demonstrated

- ELT architecture
- Incremental processing and upserts
- Data deduplication
- Data validation and quarantine
- SCD Type 2 historical tracking
- Data quality and reconciliation testing
- Dimensional and analytical modeling
- Modular SQL transformations

## Future Improvements

- Apache Airflow orchestration
- Automated ingestion workflows
- CI/CD using GitHub Actions
- Monitoring and observability
- Additional data quality thresholds

## Author

**fxtrivino**

[GitHub Profile](https://github.com/fxtrivino)