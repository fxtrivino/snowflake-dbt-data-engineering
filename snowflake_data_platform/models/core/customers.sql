
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='CUSTOMER_ID',
    schema='CORE',
    alias='CUSTOMERS',
    on_schema_change='fail'
) }}

WITH valid_customers AS (
    SELECT
        CUSTOMER_ID,
        NAME,
        EMAIL,
        COUNTRY,
        UPDATED_AT
    FROM {{ ref('stg_customers') }}
    WHERE VALIDATION_STATUS = 'VALID'
),

deduplicated AS (
    SELECT *
    FROM valid_customers
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY CUSTOMER_ID
        ORDER BY UPDATED_AT DESC
    ) = 1
),

incremental_records AS (
    SELECT
        src.CUSTOMER_ID,
        src.NAME,
        src.EMAIL,
        src.COUNTRY,
        src.UPDATED_AT
    FROM deduplicated src

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} dest
        WHERE dest.CUSTOMER_ID = src.CUSTOMER_ID
          AND dest.UPDATED_AT >= src.UPDATED_AT
    )

    {% endif %}
)

SELECT *
FROM incremental_records
