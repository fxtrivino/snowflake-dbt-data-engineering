{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT
        ORDER_ID,
        CUSTOMER_ID,
        ORDER_DATE,
        TOTAL_AMOUNT,
        STATUS,
        UPDATED_AT
    FROM {{ source('raw', 'orders_raw') }}
),

typed_data AS (
    SELECT
        TRY_TO_NUMBER(ORDER_ID) AS ORDER_ID,
        TRY_TO_NUMBER(CUSTOMER_ID) AS CUSTOMER_ID,
        TRY_TO_DATE(ORDER_DATE) AS ORDER_DATE,
        TRY_TO_DECIMAL(TOTAL_AMOUNT, 18, 2) AS TOTAL_AMOUNT,
        UPPER(TRIM(STATUS)) AS STATUS,
        TRY_TO_TIMESTAMP_NTZ(UPDATED_AT) AS UPDATED_AT
    FROM source_data
),

validated AS (
    SELECT
        *,
        CASE
            WHEN ORDER_ID IS NULL
                THEN 'INVALID_ORDER_ID'
            WHEN CUSTOMER_ID IS NULL
                THEN 'INVALID_CUSTOMER_ID'
            WHEN ORDER_DATE IS NULL
                THEN 'INVALID_ORDER_DATE'
            WHEN TOTAL_AMOUNT IS NULL OR TOTAL_AMOUNT <= 0
                THEN 'INVALID_TOTAL_AMOUNT'
            WHEN STATUS IS NULL
                 OR STATUS NOT IN ('CREATED', 'CONFIRMED', 'CANCELLED')
                THEN 'INVALID_STATUS'
            WHEN UPDATED_AT IS NULL
                THEN 'INVALID_UPDATED_AT'
            ELSE 'VALID'
        END AS VALIDATION_STATUS
    FROM typed_data
)

SELECT * FROM validated