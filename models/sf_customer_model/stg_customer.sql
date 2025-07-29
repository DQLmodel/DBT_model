with stg_customer as (
    SELECT * FROM DQLABS_QA.DBT_CORE.STG_CUSTOMER_1
    A.ITEM_GROSSAMOUNT
)
select * from stg_customer
