{{ config(
    schema='CONS',
    materialized='table'
) }}

SELECT
    "Underwriting Reference" as Underwriting_Reference,
    "Underwriter" as Underwriter,
    "Class Type" as Class_Type,
    "Major Class" as Major_Class,
    "Minor Class" as Minor_Class,
    "Policy Line Status" as Policy_Line_Status,
    "Inception Date" as Inception_Date,
    "Expiry Date" as Expiry_Date,
    "SignedLine" as SignedLine,
    "WrittenLine" as WrittenLine,
    "Assured" as Assured,
    "Broker Name" as Broker_Name
FROM {{ ref('cur_underwriting_fact') }}
WHERE Class_Type = 'CREDIT'

