
{{ config(
    materialized='table',
    schema='MARTS',
    alias='CUSTOMERS_BY_COUNTRY'
) }}

SELECT
    COUNTRY,
    COUNT(*) AS TOTAL_CUSTOMERS,
    CURRENT_TIMESTAMP() AS UPDATED_AT
FROM {{ ref('customers') }}
GROUP BY COUNTRY
