{{
    config(
        materialized='view'
    )
}}

/*
    Staging model: stg_products
    Source: {{ source('raw', 't_products') }}
    Generated: 2026-09-07T10:10:50Z
*/

with source as (
    select * from {{ source('raw', 't_products') }}
),

renamed as (
    select
        INDEX as index,
        INTERNAL_ID as internal_id,
        NAME as name,
        DESCRIPTION as description,
        BRAND as brand,
        CATEGORY as category,
        cast(PRICE as FLOAT) as price,
        CURRENCY as currency,
        cast(STOCK as NUMBER(38,0)) as stock,
        EAN as ean,
        COLOR as color,
        SIZE as size,
        AVAILABILITY as availability,
        LOADED_AT as loaded_at,
        SOURCE_OF_RECORD as source_of_record,
        EXTRACTED_AT as extracted_at,
        ROW_NUMBER as row_number,
        ROW_HASH as row_hash,
        KEY_HASH as key_hash
    from source
)

select * from renamed
