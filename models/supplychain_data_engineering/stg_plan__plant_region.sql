{{ config(materialized='view', schema='STG_PLAN', database='PROD_SC_HUB') }}

select
    trim(plant_id) as plant_id,
    trim(region) as region,
    trim(country) as country,
    trim(planner_group) as planner_group
from {{ ref('plant_region_map') }}
