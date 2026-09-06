{{
    config(
        materialized='view'
    )
}}

/*
    Staging model: stg_products_v2
    Source: {{ source('raw', 't_products') }}
    Generated: 2026-09-06T04:22:31Z
*/

with source as (
    select * from {{ source('raw', 't_products') }}
),

renamed as (
    select
        INDEX as index,
        NAME as name,
        BRAND as brand,
        CATEGORY as category,
        PRICE as price,
        STOCK as stock
    from source
)

select * from renamed
