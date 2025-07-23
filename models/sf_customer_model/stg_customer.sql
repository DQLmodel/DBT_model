with stg_customer as (
    SELECT * FROM DQLABS_QA.DBT_CORE.STG_CUSTOMER_1
)
select id from stg_customer
