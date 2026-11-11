{% snapshot customers_snapshot %}

{{
    config(
        target_database='DATA_ENGINEERING_LAB',
        target_schema='CORE',
        unique_key='CUSTOMER_ID',
        strategy='timestamp',
        updated_at='UPDATED_AT',
        invalidate_hard_deletes=False
    )
}}

SELECT
    CUSTOMER_ID,
    NAME,
    EMAIL,
    COUNTRY,
    UPDATED_AT
FROM {{ ref('customers') }}

{% endsnapshot %}
