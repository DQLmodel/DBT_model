{{ config(materialized='view', schema='INT_SUPPLY', database='PROD_SC_HUB') }}

select
    ms.material_id,
    ms.material_desc,
    ms.material_type,
    ms.plant_id,
    ms.region,
    ms.country,
    ms.stock_qty,
    ms.blocked_qty,
    ms.unrestricted_qty,
    md.total_forecast_qty,
    md.safety_stock_qty,
    (coalesce(ms.unrestricted_qty, 0) - coalesce(md.safety_stock_qty, 0)) as stock_vs_safety_gap,
    (coalesce(ms.unrestricted_qty, 0) - coalesce(md.total_forecast_qty, 0)) as stock_vs_forecast_gap,
    case
        when coalesce(ms.unrestricted_qty, 0) < coalesce(md.safety_stock_qty, 0) then 'HIGH'
        when coalesce(ms.unrestricted_qty, 0) < coalesce(md.total_forecast_qty, 0) then 'MEDIUM'
        else 'LOW'
    end as supply_risk,
    ms.valuation_class,
    ms.std_cost,
    ms.currency,
    ms.snapshot_date
from {{ ref('int_supply__material_stock') }} ms
left join {{ ref('int_supply__material_demand') }} md
    on ms.material_id = md.material_id
   and ms.plant_id = md.plant_id
