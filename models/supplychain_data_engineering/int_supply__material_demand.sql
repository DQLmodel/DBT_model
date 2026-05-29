{{ config(materialized='view', schema='INT_SUPPLY', database='PROD_SC_HUB') }}

select
    f.material_id,
    f.plant_id,
    sum(f.forecast_qty) as total_forecast_qty,
    max(ss.safety_stock_qty) as safety_stock_qty,
    min(f.forecast_month) as first_forecast_month,
    max(f.forecast_month) as last_forecast_month
from {{ ref('stg_plan__forecast') }} f
left join {{ ref('stg_plan__safety_stock') }} ss
    on f.material_id = ss.material_id
   and f.plant_id = ss.plant_id
group by
    f.material_id,
    f.plant_id
