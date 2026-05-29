{{ config(materialized='table', schema='CUR_INV', database='PROD_SC_HUB') }}

select
    region,
    country,
    plant_id,
    supply_risk,
    count(*) as material_count,
    sum(unrestricted_qty) as total_unrestricted_qty,
    sum(total_forecast_qty) as total_forecast_qty,
    sum(safety_stock_qty) as total_safety_stock_qty,
    sum(stock_vs_safety_gap) as total_stock_vs_safety_gap,
    sum(stock_vs_forecast_gap) as total_stock_vs_forecast_gap
from {{ ref('cur_inv__inventory_health') }}
group by
    region,
    country,
    plant_id,
    supply_risk
