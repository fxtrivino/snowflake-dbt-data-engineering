{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='PAYMENT_ID',
    schema='CORE',
    alias='PAYMENTS',
    on_schema_change='fail'
) }}

WITH valid_payments AS (
    SELECT
        PAYMENT_ID,
        ORDER_ID,
        PAYMENT_DATE,
        AMOUNT,
        PAYMENT_METHOD,
        STATUS,
        UPDATED_AT
    FROM {{ ref('stg_payments') }}
    WHERE VALIDATION_STATUS = 'VALID'
),

deduplicated AS (
    SELECT *
    FROM valid_payments
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY PAYMENT_ID
        ORDER BY UPDATED_AT DESC
    ) = 1
),

referential_validation AS (
    SELECT p.*
    FROM deduplicated p
    INNER JOIN {{ ref('orders') }} o
        ON p.ORDER_ID = o.ORDER_ID
),

incremental_records AS (
    SELECT src.*
    FROM referential_validation src

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} dest
        WHERE dest.PAYMENT_ID = src.PAYMENT_ID
          AND dest.UPDATED_AT >= src.UPDATED_AT
    )

    {% endif %}
)

SELECT *
FROM incremental_records