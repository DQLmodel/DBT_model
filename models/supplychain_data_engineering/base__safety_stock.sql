{{ config(materialized='view', schema='BASE', database='PROD_SC_HUB') }}

select
    trim(material_id) as material_id,
    trim(plant_id) as plant_id,
    safety_stock_qty,
    trim(replenishment_type) as replenishment_type,
    trim(planner_id) as planner_id,
    updated_at
from {{ source('plan_raw', 'SAFETY_STOCK') }}
