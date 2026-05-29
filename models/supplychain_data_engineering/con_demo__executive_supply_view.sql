{{ config(materialized='view', schema='CON_DEMO', database='PROD_SC_HUB') }}

select
    region,
    supply_risk,
    count(*) as material_count
from {{ ref('cur_inv__inventory_health') }}
group by 1,2
