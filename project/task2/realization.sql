-- analysis.orders source

CREATE OR REPLACE VIEW analysis.orders
AS SELECT o.order_id,
    o.order_ts,
    o.user_id,
    o.bonus_payment,
    o.payment,
    o.cost,
    o.bonus_grant,
    l.status_id AS status
   FROM production.orders o
     LEFT JOIN ( 
         
        SELECT orderstatuslog.order_id,
            MAX(orderstatuslog.status_id) AS status_id
        FROM production.orderstatuslog
        GROUP BY orderstatuslog.order_id

        ) l ON l.order_id = o.order_id;
