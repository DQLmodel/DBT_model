{{ config(materialized='view', schema='STG_SALES', database='PROD_SC_HUB') }}

select
    customer_id,
    customer_name,
    country,
    region,
    customer_group,
    source_system,
    updated_at
from {{ ref('base__customer_master') }}
where dbt_valid_to is null
