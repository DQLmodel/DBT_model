with stg_orders as (
    SELECT * FROM DQLABS_QA.DBT_CORE.STG_ORDERS
)
select name2 from stg_orders
