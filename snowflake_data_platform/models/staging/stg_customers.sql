
{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT
        CUSTOMER_ID,
        NAME,
        EMAIL,
        COUNTRY,
        UPDATED_AT
    FROM {{ source('raw', 'customers_raw') }}
),

typed_data AS (
    SELECT
        TRY_TO_NUMBER(CUSTOMER_ID) AS CUSTOMER_ID,
        TRIM(NAME) AS NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        NULLIF(TRIM(COUNTRY), '') AS COUNTRY,
        TRY_TO_TIMESTAMP_NTZ(UPDATED_AT) AS UPDATED_AT
    FROM source_data
),

validated AS (
    SELECT
        *,
        CASE
            WHEN CUSTOMER_ID IS NULL
                THEN 'INVALID_CUSTOMER_ID'
            WHEN EMAIL IS NULL
                 OR NOT REGEXP_LIKE(
                     EMAIL,
                     '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$'
                 )
                THEN 'INVALID_EMAIL'
            WHEN COUNTRY IS NULL
                THEN 'INVALID_COUNTRY'
            WHEN UPDATED_AT IS NULL
                THEN 'INVALID_UPDATED_AT'
            ELSE 'VALID'
        END AS VALIDATION_STATUS
    FROM typed_data
)

SELECT * FROM validated
