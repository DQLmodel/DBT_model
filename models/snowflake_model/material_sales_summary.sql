{{ config(materialized='table') }}

select
    sales_org,
    distribution_channel,
    abc_category,
    count(distinct material_id)           as material_count,
    count_if(is_gds_relevant)              as gds_material_count
from {{ ref('dim_material_sales') }}
group by
    sales_org,
    distribution_channel,
    abc_category

