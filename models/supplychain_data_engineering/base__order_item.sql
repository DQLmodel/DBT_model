{{ config(materialized='view', schema='BASE', database='PROD_SC_HUB') }}

select
    trim(order_id) as order_id,
    trim(item_id) as item_id,
    trim(material_id) as material_id,
    trim(plant_id) as plant_id,
    ordered_qty,
    confirmed_qty,
    open_qty,
    net_value,
    trim(currency) as currency,
    trim(source_system) as source_system,
    updated_at
from {{ source('sales_raw', 'ORDER_ITEM') }}
