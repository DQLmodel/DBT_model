{{ config(materialized='view', schema='BASE', database='PROD_SC_HUB') }}

select
    trim(parent_material_id) as parent_material_id,
    trim(component_material_id) as component_material_id,
    trim(plant_id) as plant_id,
    component_qty,
    scrap_pct,
    trim(source_system) as source_system,
    updated_at,
    dbt_valid_from,
    dbt_valid_to
from {{ ref('bom_item_snapshot') }}
