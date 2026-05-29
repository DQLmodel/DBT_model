{{ config(materialized='table', schema='CUR_COMM', database='PROD_SC_HUB') }}

select
    order_id,
    customer_id,
    customer_name,
    customer_country,
    customer_region,
    item_id,
    material_id,
    plant_id,
    ordered_qty,
    confirmed_qty,
    open_qty,
    net_value,
    currency,
    order_date,
    requested_delivery_date,
    order_status,
    delivery_bucket
from {{ ref('int_sales__open_orders') }}
