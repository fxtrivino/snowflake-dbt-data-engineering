
WITH snapshot_count AS (
    SELECT COUNT(*) AS TOTAL
    FROM {{ ref('customers_snapshot') }}
),

mart_count AS (
    SELECT COUNT(*) AS TOTAL
    FROM {{ ref('customer_history') }}
)

SELECT
    snapshot_count.TOTAL AS SNAPSHOT_TOTAL,
    mart_count.TOTAL AS MART_TOTAL
FROM snapshot_count
CROSS JOIN mart_count
WHERE snapshot_count.TOTAL != mart_count.TOTAL
