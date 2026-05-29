{{ config(materialized='view', schema='BASE', database='PROD_SC_HUB') }}

select
    trim(order_id) as order_id,
    trim(customer_id) as customer_id,
    order_date,
    requested_delivery_date,
    upper(trim(order_status)) as order_status,
    trim(sales_org) as sales_org,
    trim(distribution_channel) as distribution_channel,
    trim(source_system) as source_system,
    updated_at
from {{ source('sales_raw', 'ORDER_HEADER') }}
