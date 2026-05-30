-- ============================================================
-- Project   : Sales Analysis Q2 2024
-- Source    : sales_2024.csv
-- Generated : 2026-05-30T15:56:40.138696
-- Author    : CodeAct SQL Agent
-- Description: Revenue analysis and sales trends for Q2 2024
-- ============================================================


-- ============================================================
-- SECTION 1: Table Definitions
-- ============================================================

CREATE TABLE IF NOT EXISTS sales_2024 (
    sale_id         BIGINT PRIMARY KEY,
    customer_id     BIGINT NOT NULL,
    product_code    VARCHAR(50) NOT NULL,
    sale_amount     DOUBLE PRECISION NOT NULL,
    sale_date       DATE NOT NULL,
    region          VARCHAR(100) NOT NULL,
    channel         VARCHAR(100),
    notes           TEXT
);


-- ============================================================
-- SECTION 2: Indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_sales_2024_sale_date
    ON sales_2024 (sale_date);

CREATE INDEX IF NOT EXISTS idx_sales_2024_region
    ON sales_2024 (region);

CREATE INDEX IF NOT EXISTS idx_sales_2024_customer_id
    ON sales_2024 (customer_id);


-- ============================================================
-- SECTION 3: Analysis Queries
-- ============================================================

-- Query 1: Total revenue by region
SELECT
    region,
    COUNT(*)         AS total_transactions,
    SUM(sale_amount) AS total_revenue,
    AVG(sale_amount) AS avg_transaction_value
FROM
    sales_2024
GROUP BY
    region
ORDER BY
    total_revenue DESC;


-- Query 2: Monthly sales trend
SELECT
    DATE_TRUNC('month', sale_date) AS month,
    COUNT(*)                       AS total_transactions,
    SUM(sale_amount)               AS monthly_revenue,
    AVG(sale_amount)               AS avg_transaction_value
FROM
    sales_2024
GROUP BY
    DATE_TRUNC('month', sale_date)
ORDER BY
    month ASC;


-- Query 3: Top performing channels
SELECT
    channel,
    COUNT(*)         AS total_sales,
    SUM(sale_amount) AS channel_revenue,
    AVG(sale_amount) AS avg_sale_amount
FROM
    sales_2024
WHERE
    channel IS NOT NULL
GROUP BY
    channel
ORDER BY
    channel_revenue DESC;


-- ============================================================
-- Summary Statistics
-- ============================================================

-- Total Revenue: $69,988.50
-- Average Transaction: $1,399.77
-- Unique Regions: 4
-- Total Records: 50

-- ============================================================
-- End of file
-- Generated queries: 3
-- Tables created:    1
-- ============================================================
