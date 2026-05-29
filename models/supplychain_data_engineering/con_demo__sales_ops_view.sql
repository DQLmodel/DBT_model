{{ config(materialized='view', schema='CON_DEMO', database='PROD_SC_HUB') }}

select
    customer_name,
    count(distinct order_id) as open_orders,
    sum(open_qty) as total_open_qty
from {{ ref('cur_comm__sales_backlog') }}
group by 1
