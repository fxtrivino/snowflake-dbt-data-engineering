
WITH latest_valid_customers AS (
    SELECT CUSTOMER_ID
    FROM {{ ref('stg_customers') }}
    WHERE VALIDATION_STATUS = 'VALID'
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY CUSTOMER_ID
        ORDER BY UPDATED_AT DESC
    ) = 1
),

expected_count AS (
    SELECT COUNT(*) AS TOTAL
    FROM latest_valid_customers
),

actual_count AS (
    SELECT COUNT(*) AS TOTAL
    FROM {{ ref('customers') }}
)

SELECT
    expected_count.TOTAL AS EXPECTED,
    actual_count.TOTAL AS ACTUAL
FROM expected_count
CROSS JOIN actual_count
WHERE expected_count.TOTAL != actual_count.TOTAL
