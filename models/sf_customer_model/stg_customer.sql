with stg_customer as (
    SELECT * FROM DQLABS_QA.DBT_CORE.STG_CUSTOMER_1
    A.ITEM_GROSSAMOUNT,
    A.ITEM_NETAMOUNT,
    A.PRODUCTID 
)
select * from stg_customer
