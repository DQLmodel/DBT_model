{{ config(materialized='view', schema='STG_ERP', database='PROD_SC_HUB') }}

select
    parent_material_id,
    component_material_id,
    plant_id,
    component_qty,
    scrap_pct,
    source_system,
    updated_at
from {{ ref('base__bom_item') }}
where dbt_valid_to is null
