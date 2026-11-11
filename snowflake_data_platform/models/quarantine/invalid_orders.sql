{{ config(
    materialized='table',
    schema='QUARANTINE',
    alias='INVALID_ORDERS'
) }}

WITH orders AS (
    SELECT *
    FROM {{ ref('stg_orders') }}
),

valid_customers AS (
    SELECT CUSTOMER_ID
    FROM {{ ref('customers') }}
),

validated AS (
    SELECT
        o.*,
        CASE
            WHEN o.VALIDATION_STATUS <> 'VALID'
                THEN o.VALIDATION_STATUS

            WHEN c.CUSTOMER_ID IS NULL
                THEN 'CUSTOMER_NOT_FOUND'

            ELSE 'VALID'
        END AS ERROR_REASON
    FROM orders o
    LEFT JOIN valid_customers c
        ON o.CUSTOMER_ID = c.CUSTOMER_ID
)

SELECT *
FROM validated
WHERE ERROR_REASON <> 'VALID'