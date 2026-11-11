{{ config(
    materialized='table',
    schema='QUARANTINE',
    alias='INVALID_PAYMENTS'
) }}

WITH payments AS (
    SELECT *
    FROM {{ ref('stg_payments') }}
),

valid_orders AS (
    SELECT o.ORDER_ID
    FROM {{ ref('stg_orders') }} o
    INNER JOIN {{ ref('customers') }} c
        ON o.CUSTOMER_ID = c.CUSTOMER_ID
    WHERE o.VALIDATION_STATUS = 'VALID'
),

validated AS (
    SELECT
        p.*,
        CASE
            WHEN p.VALIDATION_STATUS <> 'VALID'
                THEN p.VALIDATION_STATUS

            WHEN o.ORDER_ID IS NULL
                THEN 'ORDER_NOT_FOUND'

            ELSE 'VALID'
        END AS ERROR_REASON
    FROM payments p
    LEFT JOIN valid_orders o
        ON p.ORDER_ID = o.ORDER_ID
)

SELECT *
FROM validated
WHERE ERROR_REASON <> 'VALID'