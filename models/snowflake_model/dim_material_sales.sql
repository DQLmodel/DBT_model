{{ config(
    materialized='table',
    unique_key=['client','material_id','sales_org','distribution_channel']
) }}

with ranked as (
    select *,
           row_number() over (
               partition by client, material_id, sales_org, distribution_channel
               order by ingestion_ts desc
           ) as rn
    from {{ ref('stg_mvke') }}
    where is_deleted = false
)

select
    cliente,
    material_id,
    sales_org,
    distribution_channel,

    sales_status,
    sales_status_date,

    product_hierarchy,
    item_category,

    variant,
    sku,
    abc_category,
    is_gds_relevant,

    san_registration_start_date,
    san_registration_end_date,

    ingestion_ts,
    source_system
from ranked
where rn = 1

