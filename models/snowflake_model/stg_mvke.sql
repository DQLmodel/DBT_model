{{ config(materialized='view', tags=['mvke', 'staging', 'critical']) }}

select
    -- Keys
    trim("Matnr")                                     as material_id,
    trim("Vkorg")                                     as sales_org,
    lpad("Vtweg"::varchar, 2, '0')                     as distribution_channel,

    -- Status / Flags
    lvorm = 'X'                                     as is_deleted,
    vmsta                                           as sales_status,

    -- Quantities
    aumng                                           as min_order_qty,
    lfmng                                           as delivery_qty,
    efmng                                           as confirmed_qty,

    -- Product attributes
    prodh                                           as product_hierarchy,
    mtpos                                           as item_category,
    pmatn                                           as pricing_reference_material,

    -- Custom / Z fields
    zz_variant                                      as variant,
    zz_sku                                          as sku,
    zz_abc                                          as abc_category,
    zzgds_relevant = 'X'                            as is_gds_relevant,

    -- Dates (SAP NUM → DATE)
    case
        when vmstd in ('00000000', '0', '', null) then null
        else to_date(to_varchar(vmstd), 'YYYYMMDD')
    end as sales_status_date,
    case
        when zsan_reg_bdat in ('00000000', '0', '', null) then null
        else to_date(to_varchar(zsan_reg_bdat), 'YYYYMMDD')
    end as san_registration_start_date,
    case
        when zsan_reg_edat in ('00000000', '0', '', null) then null
        else to_date(to_varchar(zsan_reg_edat), 'YYYYMMDD')
    end as san_registration_end_date,

    -- Ingestion metadata
    try_to_timestamp_ntz(ingestion_timestamp)       as ingestion_ts,
    soursystem                                      as source_system

from {{ source('sap_raw', 'mvke') }}

