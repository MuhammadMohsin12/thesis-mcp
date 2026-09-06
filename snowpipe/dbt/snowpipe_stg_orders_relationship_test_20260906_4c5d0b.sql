version: 2

models:
  - name: stg_orders
    description: "Staged orders from raw source"
    columns:
      - name: order_key
        tests:
          - unique
          - not_null
      - name: customer_key
        tests:
          - not_null
          - relationships:
              to: ref('stg_customers')
              field: customer_key

  - name: stg_customers
    description: "Staged customers from raw source"
    columns:
      - name: customer_key
        tests:
          - unique
          - not_null
