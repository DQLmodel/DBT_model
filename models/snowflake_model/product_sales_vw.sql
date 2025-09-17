{{ config(tags=["staging", "etl"]) }}

with product_sales_vw as (
SELECT PRODUCTID, TOTAL_AMOUNT AS TOTAL_AMOUNT_SALES,
 A.ITEM_NETAMOUNT,
 A.ITEM_TAXAMOUNT,
 A.NAME,
 A.ITEM_GROSSAMOUNTT,
 A.PRODUCTID 
FROM DQLABS_QA.STAGING.PRODUCT_SALES
)
select * from product_sales_vw
