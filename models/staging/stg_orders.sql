{{
    config(
        materialized='view'
    )
}}

/*
    Staging model: stg_orders
    Source: {{ source('raw', 'raw_orders') }}
    Generated: 2026-09-06T15:33:57Z
*/

with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        ORDER_ID as order_key,
        CUSTOMER_ID as customer_key,
        CUSTOMER_EMAIL as customer_email,
        ORDER_DATE as order_date,
        STATUS as status,
        TOTAL_AMOUNT as total_amount
    from source
    where ORDER_ID is not null
)

select * from renamed
