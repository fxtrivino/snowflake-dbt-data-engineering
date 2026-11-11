{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ORDER_ID',
    schema='CORE',
    alias='ORDERS',
    on_schema_change='fail'
) }}

WITH valid_orders AS (
    SELECT
        o.ORDER_ID,
        o.CUSTOMER_ID,
        o.ORDER_DATE,
        o.TOTAL_AMOUNT,
        o.STATUS,
        o.UPDATED_AT
    FROM {{ ref('stg_orders') }} o
    WHERE o.VALIDATION_STATUS = 'VALID'
),

deduplicated AS (
    SELECT *
    FROM valid_orders
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY ORDER_ID
        ORDER BY UPDATED_AT DESC
    ) = 1
),

referential_validation AS (
    SELECT o.*
    FROM deduplicated o
    INNER JOIN {{ ref('customers') }} c
        ON o.CUSTOMER_ID = c.CUSTOMER_ID
),

incremental_records AS (
    SELECT src.*
    FROM referential_validation src

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} dest
        WHERE dest.ORDER_ID = src.ORDER_ID
          AND dest.UPDATED_AT >= src.UPDATED_AT
    )

    {% endif %}
)

SELECT *
FROM incremental_records