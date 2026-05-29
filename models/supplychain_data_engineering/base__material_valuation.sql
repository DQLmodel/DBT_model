{{ config(materialized='view', schema='BASE', database='PROD_SC_HUB') }}

select
    trim(material_id) as material_id,
    trim(plant_id) as plant_id,
    trim(valuation_class) as valuation_class,
    std_cost,
    moving_price,
    trim(currency) as currency,
    trim(source_system) as source_system,
    updated_at,
    dbt_valid_from,
    dbt_valid_to
from {{ ref('material_valuation_snapshot') }}
