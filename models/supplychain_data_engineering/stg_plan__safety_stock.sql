{{ config(materialized='view', schema='STG_PLAN', database='PROD_SC_HUB') }}

select
    material_id,
    plant_id,
    safety_stock_qty,
    replenishment_type,
    planner_id,
    updated_at
from {{ ref('base__safety_stock') }}
