{{ config(materialized='view', schema='INT_SUPPLY', database='PROD_SC_HUB') }}

select
    oh.order_id,
    oh.customer_id,
    c.customer_name,
    c.country as customer_country,
    c.region as customer_region,
    oi.item_id,
    oi.material_id,
    oi.plant_id,
    oi.ordered_qty,
    oi.confirmed_qty,
    oi.open_qty,
    oi.net_value,
    oi.currency,
    oh.order_date,
    oh.requested_delivery_date,
    oh.order_status,
    case
        when oh.requested_delivery_date < current_date then 'OVERDUE'
        when datediff(day, current_date, oh.requested_delivery_date) <= 3 then 'DUE_SOON'
        else 'FUTURE'
    end as delivery_bucket
from {{ ref('stg_sales__orders') }} oh
join {{ ref('stg_sales__order_items') }} oi
    on oh.order_id = oi.order_id
left join {{ ref('stg_sales__customers') }} c
    on oh.customer_id = c.customer_id
where oi.open_qty > 0
  and oh.order_status in ('OPEN', 'PARTIAL')
