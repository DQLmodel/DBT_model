{{ config(materialized='view', schema='INT_SUPPLY', database='PROD_SC_HUB') }}

select
    ps.material_id,
    ps.plant_id,
    pr.region,
    pr.country,
    ps.stock_qty,
    ps.blocked_qty,
    ps.unrestricted_qty,
    ps.snapshot_date,
    m.material_desc,
    m.material_type,
    m.base_uom,
    v.valuation_class,
    v.std_cost,
    v.moving_price,
    v.currency
from {{ ref('stg_erp__plant_stock') }} ps
left join {{ ref('stg_plan__plant_region') }} pr
    on ps.plant_id = pr.plant_id
left join {{ ref('stg_erp__current_material') }} m
    on ps.material_id = m.material_id
   and ps.plant_id = m.plant_id
left join {{ ref('stg_erp__current_valuation') }} v
    on ps.material_id = v.material_id
   and ps.plant_id = v.plant_id
