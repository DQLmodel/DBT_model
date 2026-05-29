{{ config(materialized='view', schema='BASE', database='PROD_SC_HUB') }}

select
    trim(material_id) as material_id,
    trim(plant_id) as plant_id,
    forecast_month,
    forecast_qty,
    trim(demand_type) as demand_type,
    trim(planner_id) as planner_id,
    updated_at
from {{ source('plan_raw', 'FORECAST_PLAN') }}
