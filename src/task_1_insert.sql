INSERT INTO de.analysis.dm_rfm_segments 

WITH orders_filtered AS (
    SELECT
        user_id,
        order_ts,
        status,
        payment
    FROM
        de.analysis.orders
    WHERE
        date_part('year', order_ts) >= 2021
        AND status = 5
),
past_since_last_order AS (
    SELECT
        user_id,
        MIN(EXTRACT(epoch FROM NOW() - order_ts)::INT
        ) past_since_last_order
    FROM
        orders_filtered
    GROUP BY
        user_id
),
orders_quantity AS (
    SELECT
        user_id,
        COUNT(1) AS orders_quantity
    FROM
        orders_filtered
    GROUP BY
        user_id
),
total_spent AS (
    SELECT
        user_id,
        SUM(payment) AS total_spent
    FROM
        orders_filtered
    GROUP BY
        user_id
)
SELECT
    id AS user_id,
    NTILE(5) OVER (
        ORDER BY
            COALESCE(p.past_since_last_order, 9 * 10 ^ 6) DESC
    ) recency,
    NTILE(5) OVER (
        ORDER BY
            COALESCE(o.orders_quantity, 0)
    ) frequency,
    NTILE(5) OVER (
        ORDER BY
            COALESCE(t.total_spent, 0)
    ) monetary_value
FROM
    de.analysis.users u
    LEFT JOIN past_since_last_order p ON p.user_id = u.id
    LEFT JOIN orders_quantity o ON o.user_id = u.id
    LEFT JOIN total_spent t ON t.user_id = u.id
