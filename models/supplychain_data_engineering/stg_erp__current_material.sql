{{ config(materialized='view', schema='STG_ERP', database='PROD_SC_HUB') }}

select
    material_id,
    material_desc,
    material_type,
    base_uom,
    plant_id,
    source_system,
    updated_at
from {{ ref('base__material_master') }}
where dbt_valid_to is null
