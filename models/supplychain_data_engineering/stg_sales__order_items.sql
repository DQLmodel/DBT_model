{{ config(materialized='view', schema='STG_SALES', database='PROD_SC_HUB') }}

select
    order_id,
    item_id,
    material_id,
    plant_id,
    ordered_qty,
    confirmed_qty,
    open_qty,
    net_value,
    currency,
    source_system,
    updated_at
from {{ ref('base__order_item') }}
