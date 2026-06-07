/*
================================================================================
  SRC_0037 - SALES_DATA SNOWPIPE INGESTION (AZURE)
================================================================================
  Cloud:      Azure Blob Storage
  Database:   SRC_0037
  Schema:     RAW
  Generated:  2026-06-07T21:55:21Z

  Components (6 - Azure pattern):
    1. Storage Integration:      AZURE_INT_SALES_DATA
    2. Notification Integration: NOTIF_INT_SALES_DATA  <- AZURE ONLY
    3. File Format:              SRC_0037.RAW.FILEFORMAT_SALES_DATA
    4. Stage:                    SRC_0037.RAW.EXT_STAGE_SALES_DATA
    5. Table:                    SRC_0037.RAW.SALES_DATA
    6. Pipe:                     SRC_0037.RAW.PIPE_SALES_DATA
================================================================================
*/


-- ============================================================================
-- 1. STORAGE INTEGRATION
-- ============================================================================
-- Connects Snowflake to Azure Blob Storage via service principal.

CREATE OR REPLACE STORAGE INTEGRATION AZURE_INT_SALES_DATA
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'AZURE'
    ENABLED = TRUE
    AZURE_TENANT_ID = '12312312312312321'
    STORAGE_ALLOWED_LOCATIONS = ('azure://myaccount.blob.core.windows.net/cntthesis/');


-- ============================================================================
-- 2. NOTIFICATION INTEGRATION (AZURE ONLY)
-- ============================================================================
-- Required for Azure auto-ingest. Receives events from Azure Storage Queue.

CREATE OR REPLACE NOTIFICATION INTEGRATION NOTIF_INT_SALES_DATA
    ENABLED = TRUE
    TYPE = QUEUE
    NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
    AZURE_STORAGE_QUEUE_PRIMARY_URI = '/myaccount.blob.core.windows.net/cntthesis/'
    AZURE_TENANT_ID = '12312312312312321';


-- ============================================================================
-- 3. FILE FORMAT
-- ============================================================================

CREATE OR REPLACE FILE FORMAT SRC_0037.RAW.FILEFORMAT_SALES_DATA
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    ESCAPE_UNENCLOSED_FIELD = 'NONE'
    TRIM_SPACE = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('#');


-- ============================================================================
-- 4. STAGE
-- ============================================================================

CREATE OR REPLACE STAGE SRC_0037.RAW.EXT_STAGE_SALES_DATA
    URL = 'azure://myaccount.blob.core.windows.net/cntthesis/'
    STORAGE_INTEGRATION = AZURE_INT_SALES_DATA
    FILE_FORMAT = (FORMAT_NAME = 'SRC_0037.RAW.FILEFORMAT_SALES_DATA');


-- ============================================================================
-- 5. TABLE (20 columns)
-- ============================================================================

CREATE OR REPLACE TABLE SRC_0037.RAW.SALES_DATA (
    LOADED_AT                                          TIMESTAMP_NTZ(9),
    SOURCE_OF_RECORD                                   VARCHAR(16777216),
    EXTRACTED_AT                                       TIMESTAMP_NTZ(9),
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
) COMMENT = 'Sales data from Azure Blob Storage'
CHANGE_TRACKING = TRUE;


-- ============================================================================
-- 6. PIPE (references NOTIFICATION INTEGRATION - Azure requirement)
-- ============================================================================

CREATE OR REPLACE PIPE SRC_0037.RAW.PIPE_SALES_DATA
    AUTO_INGEST = TRUE
    INTEGRATION = 'NOTIF_INT_SALES_DATA'
AS
COPY INTO SRC_0037.RAW.SALES_DATA
FROM (
    SELECT
        current_timestamp() loaded_at,
        METADATA$FILENAME source_of_record,
        NVL(to_timestamp_ltz(regexp_substr(metadata$filename, '\\d{14}'),
            'yyyymmddhh24miss'), CURRENT_TIMESTAMP) extracted_at,
        metadata$file_row_number row_number,
        md5(to_varchar(array_construct(T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8, T.$9, T.$10, T.$11, T.$12, T.$13, T.$14))) row_hash,
        md5(to_varchar(array_construct(T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8))) key_hash,
        T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7, T.$8, T.$9, T.$10, T.$11, T.$12, T.$13, T.$14, T.$15, T.$16, T.$17, T.$18, T.$19, T.$20
    FROM @SRC_0037.RAW.EXT_STAGE_SALES_DATA/
        (FILE_FORMAT => 'SRC_0037.RAW.FILEFORMAT_SALES_DATA') T
);


/*
================================================================================
  AZURE DATA FLOW
================================================================================

  Azure Blob Storage (azure://myaccount.blob.core.windows.net/cntthesis/)
      |
      | (Event Grid -> Storage Queue)
      v
  Notification Integration: NOTIF_INT_SALES_DATA
      |
      v
  Storage Integration: AZURE_INT_SALES_DATA
      |
      v
  External Stage: EXT_STAGE_SALES_DATA
      |
      v
  Pipe: PIPE_SALES_DATA --> Table: SALES_DATA

================================================================================
  POST-CREATION STEPS
================================================================================

  1. After creating storage integration:
       DESC INTEGRATION AZURE_INT_SALES_DATA;
     Copy AZURE_CONSENT_URL, open in browser, grant consent.

  2. After creating notification integration:
       DESC INTEGRATION NOTIF_INT_SALES_DATA;
     Copy AZURE_CONSENT_URL if shown, grant consent.

  3. Configure Event Grid subscription on the Azure container
     to send events to the Storage Queue.

  4. Test with:
       ALTER PIPE SRC_0037.RAW.PIPE_SALES_DATA REFRESH;

================================================================================
*/