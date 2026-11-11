
{{ config(
    materialized='view',
    schema='MARTS',
    alias='CUSTOMER_HISTORY'
) }}

SELECT
    CUSTOMER_ID,
    NAME,
    EMAIL,
    COUNTRY,

    DBT_VALID_FROM AS VALID_FROM,
    DBT_VALID_TO AS VALID_TO,

    CASE
        WHEN DBT_VALID_TO IS NULL THEN TRUE
        ELSE FALSE
    END AS IS_CURRENT,

    ROW_NUMBER() OVER (
        PARTITION BY CUSTOMER_ID
        ORDER BY DBT_VALID_FROM
    ) AS VERSION_NUMBER

FROM {{ ref('customers_snapshot') }}
