/*
================================================================================
  SRC_0037 - THESIS SNOWPIPE INGESTION (AZURE) - 3 PIPE(S)
================================================================================
  Cloud:      Azure Blob Storage
  Database:   SRC_0037
  Schema:     RAW
  Generated:  2026-06-18T09:15:47Z

  Shared Components (created once):
    1. Storage Integration:      AZURE_INT_THESIS
    2. Notification Integration: NOTIF_INT_THESIS
    3. File Format:              SRC_0037.RAW.FILEFORMAT_THESIS
    4. Stage:                    SRC_0037.RAW.EXT_STAGE_THESIS (points to ROOT)

  Per-Pipe Components (3 sources):
--     4. Table               : SRC_0037.RAW.T_PEOPLE
--     5. Table               : SRC_0037.RAW.T_SALES_DATA
--     6. Table               : SRC_0037.RAW.T_PRODUCTS
--     7. Pipe                : SRC_0037.RAW.PIPE_T_PEOPLE
--     8. Pipe                : SRC_0037.RAW.PIPE_T_SALES_DATA
--     9. Pipe                : SRC_0037.RAW.PIPE_T_PRODUCTS
================================================================================
*/


-- ============================================================================
-- 1. STORAGE INTEGRATION (shared)
-- ============================================================================

CREATE OR REPLACE STORAGE INTEGRATION AZURE_INT_THESIS
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'AZURE'
    ENABLED = TRUE
    AZURE_TENANT_ID = '1111222223333344444'
    STORAGE_ALLOWED_LOCATIONS = ('azure://myaccount.blob.core.windows.net/cntthesis/');


-- ============================================================================
-- 2. NOTIFICATION INTEGRATION (shared, Azure only)
-- ============================================================================

CREATE OR REPLACE NOTIFICATION INTEGRATION NOTIF_INT_THESIS
    ENABLED = TRUE
    TYPE = QUEUE
    NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
    AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://myaccount.queue.core.windows.net/myqueue'
    AZURE_TENANT_ID = '1111222223333344444';


-- ============================================================================
-- 3. FILE FORMAT (shared)
-- ============================================================================

CREATE OR REPLACE FILE FORMAT SRC_0037.RAW.FILEFORMAT_THESIS
    TYPE = 'CSV'
    FIELD_DELIMITER = '|'
    SKIP_HEADER = 1
    ESCAPE_UNENCLOSED_FIELD = 'NONE'
    TRIM_SPACE = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('#');


-- ============================================================================
-- 4. STAGE (shared, points to container ROOT)
-- ============================================================================

CREATE OR REPLACE STAGE SRC_0037.RAW.EXT_STAGE_THESIS
    URL = 'azure://myaccount.blob.core.windows.net/cntthesis/'
    STORAGE_INTEGRATION = AZURE_INT_THESIS
    FILE_FORMAT = (FORMAT_NAME = 'SRC_0037.RAW.FILEFORMAT_THESIS');


-- ============================================================================
-- 5. TABLE: T_PEOPLE
-- ============================================================================

CREATE OR REPLACE TABLE SRC_0037.RAW.T_PEOPLE (
    LOADED_AT                                          TIMESTAMP_LTZ,
    SOURCE_OF_RECORD                                   VARCHAR(16777216),
    EXTRACTED_AT                                       TIMESTAMP_LTZ,
    ROW_NUMBER                                         NUMBER(38,0),
    ROW_HASH                                           VARCHAR(16777216),
    KEY_HASH                                           VARCHAR(16777216),
    INDEX                                              VARCHAR(16777216),
    USER ID                                            VARCHAR(16777216),
    FIRST NAME                                         VARCHAR(16777216),
    LAST NAME                                          VARCHAR(16777216),
    SEX                                                VARCHAR(16777216),
    EMAIL                                              VARCHAR(16777216),
    PHONE                                              VARCHAR(16777216),
    DATE OF BIRTH                                      VARCHAR(16777216),
    JOB TITLE                                          VARCHAR(16777216)
) COMMENT = 'Data from people.csv'
CHANGE_TRACKING = TRUE;


-- ============================================================================
-- 8. PIPE: PIPE_T_PEOPLE
-- ============================================================================

CREATE OR REPLACE PIPE SRC_0037.RAW.PIPE_T_PEOPLE
    AUTO_INGEST = TRUE
    INTEGRATION = 'NOTIF_INT_THESIS'
AS
COPY INTO SRC_0037.RAW.T_PEOPLE
FROM (
    SELECT
        current_timestamp() loaded_at,
        METADATA$FILENAME source_of_record,
        NVL(to_timestamp_ltz(regexp_substr(metadata$filename, '\\d{14}'),
            'yyyymmddhh24miss'), CURRENT_TIMESTAMP) extracted_at,
        metadata$file_row_number row_number,
        md5(to_varchar(array_construct(T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8, T.$9))) row_hash,
        md5(to_varchar(array_construct(T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8))) key_hash,
        T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8, T.$9
    FROM @SRC_0037.RAW.EXT_STAGE_THESIS/
        (FILE_FORMAT => 'SRC_0037.RAW.FILEFORMAT_THESIS') T
);


-- ============================================================================
-- 6. TABLE: T_SALES_DATA
-- ============================================================================

CREATE OR REPLACE TABLE SRC_0037.RAW.T_SALES_DATA (
    LOADED_AT                                          TIMESTAMP_LTZ,
    SOURCE_OF_RECORD                                   VARCHAR(16777216),
    EXTRACTED_AT                                       TIMESTAMP_LTZ,
    ROW_NUMBER                                         NUMBER(38,0),
    ROW_HASH                                           VARCHAR(16777216),
    KEY_HASH                                           VARCHAR(16777216),
    ORDER_ID                                           VARCHAR(16777216),
    ORDER_DATE                                         VARCHAR(16777216),
    CUSTOMER_ID                                        VARCHAR(16777216),
    CUSTOMER_NAME                                      VARCHAR(16777216),
    REGION                                             VARCHAR(16777216),
    PRODUCT_ID                                         VARCHAR(16777216),
    PRODUCT_NAME                                       VARCHAR(16777216),
    CATEGORY                                           VARCHAR(16777216),
    QUANTITY                                           VARCHAR(16777216),
    UNIT_PRICE                                         VARCHAR(16777216),
    DISCOUNT                                           VARCHAR(16777216),
    TOTAL_AMOUNT                                       VARCHAR(16777216),
    PAYMENT_METHOD                                     VARCHAR(16777216),
    STATUS                                             VARCHAR(16777216)
) COMMENT = 'Data from sales_data.csv'
CHANGE_TRACKING = TRUE;


-- ============================================================================
-- 9. PIPE: PIPE_T_SALES_DATA
-- ============================================================================

CREATE OR REPLACE PIPE SRC_0037.RAW.PIPE_T_SALES_DATA
    AUTO_INGEST = TRUE
    INTEGRATION = 'NOTIF_INT_THESIS'
AS
COPY INTO SRC_0037.RAW.T_SALES_DATA
FROM (
    SELECT
        current_timestamp() loaded_at,
        METADATA$FILENAME source_of_record,
        NVL(to_timestamp_ltz(regexp_substr(metadata$filename, '\\d{14}'),
            'yyyymmddhh24miss'), CURRENT_TIMESTAMP) extracted_at,
        metadata$file_row_number row_number,
        md5(to_varchar(array_construct(T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8, T.$9, T.$10, T.$11, T.$12, T.$13, T.$14))) row_hash,
        md5(to_varchar(array_construct(T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8))) key_hash,
        T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8, T.$9, T.$10, T.$11, T.$12, T.$13, T.$14
    FROM @SRC_0037.RAW.EXT_STAGE_THESIS/
        (FILE_FORMAT => 'SRC_0037.RAW.FILEFORMAT_THESIS') T
);


-- ============================================================================
-- 7. TABLE: T_PRODUCTS
-- ============================================================================

CREATE OR REPLACE TABLE SRC_0037.RAW.T_PRODUCTS (
    LOADED_AT                                          TIMESTAMP_LTZ,
    SOURCE_OF_RECORD                                   VARCHAR(16777216),
    EXTRACTED_AT                                       TIMESTAMP_LTZ,
    ROW_NUMBER                                         NUMBER(38,0),
    ROW_HASH                                           VARCHAR(16777216),
    KEY_HASH                                           VARCHAR(16777216),
    INDEX                                              VARCHAR(16777216),
    NAME                                               VARCHAR(16777216),
    DESCRIPTION                                        VARCHAR(16777216),
    BRAND                                              VARCHAR(16777216),
    CATEGORY                                           VARCHAR(16777216),
    PRICE                                              VARCHAR(16777216),
    CURRENCY                                           VARCHAR(16777216),
    STOCK                                              VARCHAR(16777216),
    EAN                                                VARCHAR(16777216),
    COLOR                                              VARCHAR(16777216),
    SIZE                                               VARCHAR(16777216),
    AVAILABILITY                                       VARCHAR(16777216),
    INTERNAL ID                                        VARCHAR(16777216)
) COMMENT = 'Data from products.csv'
CHANGE_TRACKING = TRUE;


-- ============================================================================
-- 10. PIPE: PIPE_T_PRODUCTS
-- ============================================================================

CREATE OR REPLACE PIPE SRC_0037.RAW.PIPE_T_PRODUCTS
    AUTO_INGEST = TRUE
    INTEGRATION = 'NOTIF_INT_THESIS'
AS
COPY INTO SRC_0037.RAW.T_PRODUCTS
FROM (
    SELECT
        current_timestamp() loaded_at,
        METADATA$FILENAME source_of_record,
        NVL(to_timestamp_ltz(regexp_substr(metadata$filename, '\\d{14}'),
            'yyyymmddhh24miss'), CURRENT_TIMESTAMP) extracted_at,
        metadata$file_row_number row_number,
        md5(to_varchar(array_construct(T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8, T.$9, T.$10, T.$11, T.$12, T.$13))) row_hash,
        md5(to_varchar(array_construct(T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8))) key_hash,
        T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8, T.$9, T.$10, T.$11, T.$12, T.$13
    FROM @SRC_0037.RAW.EXT_STAGE_THESIS/
        (FILE_FORMAT => 'SRC_0037.RAW.FILEFORMAT_THESIS') T
);


/*
================================================================================
  AZURE DATA FLOW
================================================================================

  Azure Blob Storage (azure://myaccount.blob.core.windows.net/cntthesis/)
      |
      | (Event Grid -> Storage Queue)
      v
  Notification Integration: NOTIF_INT_THESIS
      |
      v
  Storage Integration: AZURE_INT_THESIS
      |
      v
  External Stage: EXT_STAGE_THESIS (ROOT)
      |
      +-- // --> PIPE_T_PEOPLE --> T_PEOPLE
      +-- // --> PIPE_T_SALES_DATA --> T_SALES_DATA
      +-- // --> PIPE_T_PRODUCTS --> T_PRODUCTS

================================================================================
  POST-CREATION STEPS
================================================================================

  1. After creating storage integration:
       DESC INTEGRATION AZURE_INT_THESIS;
     Copy AZURE_CONSENT_URL, open in browser, grant consent.

  2. After creating notification integration:
       DESC INTEGRATION NOTIF_INT_THESIS;
     Copy AZURE_CONSENT_URL if shown, grant consent.

  3. Configure Event Grid subscription on the Azure container
     to send events to the Storage Queue.

  4. Test each pipe:
       ALTER PIPE SRC_0037.RAW.PIPE_T_PEOPLE REFRESH;
       ALTER PIPE SRC_0037.RAW.PIPE_T_SALES_DATA REFRESH;
       ALTER PIPE SRC_0037.RAW.PIPE_T_PRODUCTS REFRESH;

================================================================================
*/