{{ config(
    schema='CUR',
    materialized='table'
) }}

SELECT
    ROW_NUMBER() OVER (ORDER BY "Underwriting Reference") AS underwriting_sk,
    "Underwriting Reference",
    "Underwriter",
    "Class Type",
    "Major Class",
    "Minor Class",
    "Policy Line Status",
    "Inception Date",
    "Expiry Date",
    "SignedLine",
    "WrittenLine",
    "Entity",
    "Broker Name",
    "Assured",
    "Reassured",
    "Cover Holder"
FROM {{ ref('stg_underwriting') }}
