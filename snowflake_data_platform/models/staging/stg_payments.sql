{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT
        PAYMENT_ID,
        ORDER_ID,
        PAYMENT_DATE,
        AMOUNT,
        PAYMENT_METHOD,
        STATUS,
        UPDATED_AT
    FROM {{ source('raw', 'payments_raw') }}
),

typed_data AS (
    SELECT
        TRY_TO_NUMBER(PAYMENT_ID) AS PAYMENT_ID,
        TRY_TO_NUMBER(ORDER_ID) AS ORDER_ID,
        TRY_TO_DATE(PAYMENT_DATE) AS PAYMENT_DATE,
        TRY_TO_DECIMAL(AMOUNT, 18, 2) AS AMOUNT,
        UPPER(TRIM(PAYMENT_METHOD)) AS PAYMENT_METHOD,
        UPPER(TRIM(STATUS)) AS STATUS,
        TRY_TO_TIMESTAMP_NTZ(UPDATED_AT) AS UPDATED_AT
    FROM source_data
),

validated AS (
    SELECT
        *,
        CASE
            WHEN PAYMENT_ID IS NULL
                THEN 'INVALID_PAYMENT_ID'
            WHEN ORDER_ID IS NULL
                THEN 'INVALID_ORDER_ID'
            WHEN PAYMENT_DATE IS NULL
                THEN 'INVALID_PAYMENT_DATE'
            WHEN AMOUNT IS NULL OR AMOUNT <= 0
                THEN 'INVALID_AMOUNT'
            WHEN PAYMENT_METHOD IS NULL
                 OR PAYMENT_METHOD NOT IN ('CARD', 'TRANSFER', 'CASH')
                THEN 'INVALID_PAYMENT_METHOD'
            WHEN STATUS IS NULL
                 OR STATUS NOT IN ('PENDING', 'COMPLETED', 'FAILED')
                THEN 'INVALID_STATUS'
            WHEN UPDATED_AT IS NULL
                THEN 'INVALID_UPDATED_AT'
            ELSE 'VALID'
        END AS VALIDATION_STATUS
    FROM typed_data
)

SELECT * FROM validated