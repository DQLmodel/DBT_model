{{ config(materialized='view', schema='CON_DEMO', database='PROD_SC_HUB') }}

select
    region,
    supply_risk,
    count(*) as material_count,
    sum(unrestricted_qty) as total_unrestricted_qty,
    sum(total_forecast_qty) as total_forecast_qty,
    sum(safety_stock_qty) as total_safety_stock_qty,
    avg(std_cost) as avg_std_cost
from {{ ref('cur_inv__inventory_health') }}
group by
    region,
    supply_risk
