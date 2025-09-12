with stg_orders as (
    SELECT name FROM DQLABS_QA.DBT_CORE.STG_ORDERS
)

select * from stg_orders AS main

