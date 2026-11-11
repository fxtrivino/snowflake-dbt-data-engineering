
WITH ordered_versions AS (
    SELECT
        CUSTOMER_ID,
        DBT_VALID_FROM,
        DBT_VALID_TO,

        LAG(DBT_VALID_TO) OVER (
            PARTITION BY CUSTOMER_ID
            ORDER BY DBT_VALID_FROM
        ) AS PREVIOUS_VALID_TO

    FROM {{ ref('customers_snapshot') }}
)

SELECT *
FROM ordered_versions
WHERE
    PREVIOUS_VALID_TO > DBT_VALID_FROM
    OR DBT_VALID_TO <= DBT_VALID_FROM
