{{ config(materialized='view', schema='BASE', database='PROD_SC_HUB') }}

select
    trim(material_id) as material_id,
    trim(plant_id) as plant_id,
    stock_qty,
    blocked_qty,
    unrestricted_qty,
    snapshot_date,
    trim(source_system) as source_system
from {{ source('sap_raw', 'PLANT_STOCK') }}
