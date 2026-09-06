models:
  - name: stg_orders
    description: "Staged orders from raw source"
    columns:
      - name: order_key
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - not_null
          - accepted_values:
              values:
                - completed
                - pending
                - shipped
                - cancelled
