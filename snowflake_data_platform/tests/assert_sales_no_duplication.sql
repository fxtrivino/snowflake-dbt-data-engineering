WITH expected AS (
    SELECT
        SUM(TOTAL_AMOUNT) AS TOTAL
    FROM {{ ref('orders') }}
    WHERE STATUS = 'CONFIRMED'
),

actual AS (
    SELECT
        SUM(CONFIRMED_SALES_AMOUNT) AS TOTAL
    FROM {{ ref('customer_sales') }}
)

SELECT *
FROM expected e
CROSS JOIN actual a
WHERE e.TOTAL <> a.TOTAL