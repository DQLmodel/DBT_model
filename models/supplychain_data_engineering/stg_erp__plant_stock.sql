{{ config(materialized='view', schema='STG_ERP', database='PROD_SC_HUB') }}

select
    material_id,
    plant_id,
    stock_qty,
    blocked_qty,
    unrestricted_qty,
    snapshot_date,
    source_system
from {{ ref('base__plant_stock') }}
