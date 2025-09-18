with stg_orders as (
    SELECT * FROM DQLABS_QA.DBT_CORE.STG_ORDERS
)

select uuid from stg_orders As  main

