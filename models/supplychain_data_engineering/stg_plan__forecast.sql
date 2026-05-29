{{ config(materialized='view', schema='STG_PLAN', database='PROD_SC_HUB') }}

select
    material_id,
    plant_id,
    forecast_month,
    forecast_qty,
    demand_type,
    planner_id,
    updated_at
from {{ ref('base__forecast_plan') }}
