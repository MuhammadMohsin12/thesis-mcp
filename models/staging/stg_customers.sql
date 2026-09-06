{{
    config(
        materialized='view'
    )
}}

/*
    Staging model: stg_customers
    Source: {{ source('raw', 'RAW_CUSTOMERS') }}
    Generated: 2026-09-06T05:35:21Z
*/

with source as (
    select * from {{ source('raw', 'RAW_CUSTOMERS') }}
),

renamed as (
    select
        cast(CUSTOMER_ID as VARCHAR) as customer_key,
        EMAIL as email,
        FIRST_NAME as first_name,
        LAST_NAME as last_name,
        COUNTRY as country
    from source
)

select * from renamed
