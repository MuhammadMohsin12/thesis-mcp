{{
    config(
        materialized='view'
    )
}}

/*
    Staging model: stg_orders
    Source: {{ source('raw', 'RAW_ORDERS') }}
    Generated: 2026-09-05T23:10:43Z
*/

with source as (
    select * from {{ source('raw', 'RAW_ORDERS') }}
),

renamed as (
    select
        cast(ORDER_ID as VARCHAR) as order_key,
        CUSTOMER_ID as customer_id,
        cast(CUSTOMER_EMAIL as TRIM(CUSTOMER_EMAIL)) as customer_email,
        ORDER_DATE as order_date,
        STATUS as status,
        TOTAL_AMOUNT as total_amount
    from source
    where ORDER_ID IS NOT NULL
)

select * from renamed
