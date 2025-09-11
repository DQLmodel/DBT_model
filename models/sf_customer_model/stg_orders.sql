with stg_orders as (
    SELECT * FROM DQLABS_QA.DBT_CORE.STG_ORDERS
)

select phone from stg_orders As As main

