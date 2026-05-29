{{ config(materialized='view', schema='BASE', database='PROD_SC_HUB') }}

select
    trim(customer_id) as customer_id,
    trim(customer_name) as customer_name,
    trim(country) as country,
    trim(region) as region,
    trim(customer_group) as customer_group,
    trim(source_system) as source_system,
    updated_at,
    dbt_valid_from,
    dbt_valid_to
from {{ ref('customer_master_snapshot') }}
