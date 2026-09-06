{{
    config(
        materialized='view'
    )
}}

/*
    Staging model: stg_orders
    Source: {{ source('raw', 'raw_orders') }}
    Generated: 2026-09-06T06:56:23Z
*/

with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        cast(ORDER_ID as varchar) as order_key,
        cast(CUSTOMER_ID as varchar) as customer_key,
        CUSTOMER_EMAIL as customer_email,
        ORDER_DATE as order_date,
        STATUS as status,
        TOTAL_AMOUNT as total_amount
    from source
    where ORDER_ID IS NOT NULL
)

select * from renamed
