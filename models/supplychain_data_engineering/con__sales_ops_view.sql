{{ config(materialized='view', schema='CON_DEMO', database='PROD_SC_HUB') }}

select
    customer_region,
    customer_name,
    count(distinct order_id) as open_orders,
    sum(open_qty) as total_open_qty,
    sum(net_value) as total_open_value
from {{ ref('cur_comm__sales_backlog') }}
group by
    customer_region,
    customer_name
