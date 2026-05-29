{{ config(materialized='view', schema='INT_SUPPLY', database='PROD_SC_HUB') }}

select
    b.parent_material_id,
    pm.material_desc as parent_material_desc,
    b.component_material_id,
    cm.material_desc as component_material_desc,
    b.plant_id,
    b.component_qty,
    b.scrap_pct,
    (b.component_qty * (1 + coalesce(b.scrap_pct, 0) / 100)) as effective_component_qty,
    cv.std_cost as component_std_cost,
    (b.component_qty * (1 + coalesce(b.scrap_pct, 0) / 100) * coalesce(cv.std_cost, 0)) as estimated_component_cost
from {{ ref('stg_erp__current_bom') }} b
left join {{ ref('stg_erp__current_material') }} pm
    on b.parent_material_id = pm.material_id
   and b.plant_id = pm.plant_id
left join {{ ref('stg_erp__current_material') }} cm
    on b.component_material_id = cm.material_id
   and b.plant_id = cm.plant_id
left join {{ ref('stg_erp__current_valuation') }} cv
    on b.component_material_id = cv.material_id
   and b.plant_id = cv.plant_id
