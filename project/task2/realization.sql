-- analysis.orders source
CREATE OR
REPLACE VIEW analysis.orders AS
SELECT
    o.order_id,
    o.order_ts,
    o.user_id,
    o.bonus_payment,
    o.payment,
    o.cost,
    o.bonus_grant,
    l.status_id AS status
FROM production.orders o
    LEFT JOIN (
        SELECT
            ord.order_id,
            ord.status_id,
            ROW_NUMBER() OVER(
                PARTITION BY ord.order_id
                ORDER BY ord.dttm desc
            ) rn
        FROM
            production.orderstatuslog ord
    ) l
    ON l.order_id = o.order_id AND
    l.rn = 1;