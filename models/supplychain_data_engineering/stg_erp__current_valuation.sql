{{ config(materialized='view', schema='STG_ERP', database='PROD_SC_HUB') }}

select
    material_id,
    plant_id,
    valuation_class,
    std_cost,
    moving_price,
    currency,
    source_system,
    updated_at
from {{ ref('base__material_valuation') }}
where dbt_valid_to is null
