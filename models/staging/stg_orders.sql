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
),

deduped as (
    select *,
        row_number() over (partition by order_key order by order_date) as _row_num
    from renamed
)

select
    order_key,
    customer_key,
    customer_email,
    order_date,
    status,
    total_amount
from deduped
where _row_num = 1
