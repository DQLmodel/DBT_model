with stg_orders as (
    SELECT customer_id FROM DQLABS_QA.DBT_CORE.STG_ORDERS
)

select * from stg_orders AS main

