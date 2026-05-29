{{ config(materialized='view', schema='STG_SALES', database='PROD_SC_HUB') }}

select
    order_id,
    customer_id,
    order_date,
    requested_delivery_date,
    order_status,
    sales_org,
    distribution_channel,
    source_system,
    updated_at
from {{ ref('base__order_header') }}
