{{ config(materialized='table', schema='CUR_INV', database='PROD_SC_HUB') }}

select
    material_id,
    material_desc,
    material_type,
    plant_id,
    region,
    country,
    stock_qty,
    blocked_qty,
    unrestricted_qty,
    total_forecast_qty,
    safety_stock_qty,
    stock_vs_safety_gap,
    stock_vs_forecast_gap,
    supply_risk,
    valuation_class,
    std_cost,
    currency,
    snapshot_date
from {{ ref('int_supply__risk_join') }}
