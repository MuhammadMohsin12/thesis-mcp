{{
    config(materialized='view')
}}

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
    where ORDER_ID is not null
)

select * from renamed
