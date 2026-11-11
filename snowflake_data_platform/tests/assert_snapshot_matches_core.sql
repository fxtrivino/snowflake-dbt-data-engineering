
WITH current_snapshot AS (
    SELECT
        CUSTOMER_ID,
        NAME,
        EMAIL,
        COUNTRY,
        UPDATED_AT
    FROM {{ ref('customers_snapshot') }}
    WHERE DBT_VALID_TO IS NULL
),

current_core AS (
    SELECT
        CUSTOMER_ID,
        NAME,
        EMAIL,
        COUNTRY,
        UPDATED_AT
    FROM {{ ref('customers') }}
),

differences AS (
    (
        SELECT * FROM current_snapshot
        MINUS
        SELECT * FROM current_core
    )

    UNION ALL

    (
        SELECT * FROM current_core
        MINUS
        SELECT * FROM current_snapshot
    )
)

SELECT *
FROM differences
