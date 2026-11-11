WITH expected AS (
    SELECT SUM(AMOUNT) AS TOTAL
    FROM {{ ref('payments') }}
    WHERE STATUS = 'COMPLETED'
),

actual AS (
    SELECT SUM(PAID_AMOUNT) AS TOTAL
    FROM {{ ref('customer_sales') }}
)

SELECT *
FROM expected e
CROSS JOIN actual a
WHERE e.TOTAL <> a.TOTAL