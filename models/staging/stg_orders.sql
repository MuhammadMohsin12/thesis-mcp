{{
    config(
        materialized='view'
    )
}}

/*
    Staging model: stg_orders
    Source: {{ source('raw', 'RAW_ORDERS') }}
    Generated: 2026-09-06T07:03:38Z
*/

with source as (
    select * from {{ source('raw', 'RAW_ORDERS') }}
),

renamed as (
    select
        cast(ORDER_ID as VARCHAR) as order_key,
        CUSTOMER_ID as customer_id,
        trim(CUSTOMER_EMAIL) as customer_email,
        ORDER_DATE as order_date,
        STATUS as status,
        TOTAL_AMOUNT as total_amount
    from source
    where ORDER_ID IS NOT NULL
)

select * from renamed
