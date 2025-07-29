with stg_customer as (
    SELECT * FROM DQLABS_QA.DBT_CORE.STG_CUSTOMER_1
    A.ITEM_GROSSAMOUNT,

    A.PRODUCTID 
)
select id from stg_customer
