
{{ config(
    materialized='table',
    schema='QUARANTINE',
    alias='INVALID_CUSTOMERS'
) }}

SELECT
    CUSTOMER_ID,
    NAME,
    EMAIL,
    COUNTRY,
    UPDATED_AT,
    VALIDATION_STATUS
FROM {{ ref('stg_customers') }}
WHERE VALIDATION_STATUS != 'VALID'
