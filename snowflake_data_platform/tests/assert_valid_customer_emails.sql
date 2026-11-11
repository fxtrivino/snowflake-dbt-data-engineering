
SELECT
    CUSTOMER_ID,
    EMAIL
FROM {{ ref('customers') }}
WHERE NOT REGEXP_LIKE(
    EMAIL,
    '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$'
)
