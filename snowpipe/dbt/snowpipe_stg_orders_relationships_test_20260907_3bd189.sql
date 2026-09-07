version: 2

models:
  - name: stg_orders
    description: "Staged orders data"
    columns:
      - name: order_key
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - not_null
      - name: customer_key
        tests:
          - relationships:
              to: ref('stg_customers')
              field: customer_key

  - name: stg_customers
    description: "Staged customers data"
    columns:
      - name: customer_key
        tests:
          - unique
          - not_null
