
WITH core_count AS (
    SELECT COUNT(*) AS TOTAL
    FROM {{ ref('customers') }}
),

mart_count AS (
    SELECT SUM(TOTAL_CUSTOMERS) AS TOTAL
    FROM {{ ref('customers_by_country') }}
)

SELECT
    core_count.TOTAL AS CORE_TOTAL,
    mart_count.TOTAL AS MART_TOTAL
FROM core_count
CROSS JOIN mart_count
WHERE core_count.TOTAL
      != COALESCE(mart_count.TOTAL, 0)
