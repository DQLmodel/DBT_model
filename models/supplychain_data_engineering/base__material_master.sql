{{ config(materialized='view', schema='BASE', database='PROD_SC_HUB') }}

select
    trim(material_id) as material_id,
    trim(material_desc) as material_desc,
    trim(material_type) as material_type,
    trim(base_uom) as base_uom,
    trim(plant_id) as plant_id,
    trim(source_system) as source_system,
    updated_at,
    dbt_valid_from,
    dbt_valid_to
from {{ ref('material_master_snapshot') }}
