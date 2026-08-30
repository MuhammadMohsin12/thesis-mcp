/*
================================================================================
  TEST_DB - THESIS SNOWPIPE INGESTION (AZURE) - 1 PIPE(S)
================================================================================
  Cloud:      Azure Blob Storage
  Database:   TEST_DB
  Schema:     TEST_SCHEMA
  Generated:  2026-08-30T20:44:39Z

  Shared Components (created once):
    1. Storage Integration:      AZURE_INT_THESIS
    2. Notification Integration: NOTIF_INT_THESIS
    3. File Format:              TEST_DB.TEST_SCHEMA.FILEFORMAT_THESIS
    4. Stage:                    TEST_DB.TEST_SCHEMA.EXT_STAGE_THESIS (points to ROOT)

  Per-Pipe Components (1 sources):
--     4. Table               : TEST_DB.TEST_SCHEMA.T_PRODUCTS
--     5. Pipe                : TEST_DB.TEST_SCHEMA.PIPE_T_PRODUCTS
================================================================================
*/


-- ============================================================================
-- 1. STORAGE INTEGRATION (shared)
-- ============================================================================

CREATE OR REPLACE STORAGE INTEGRATION AZURE_INT_THESIS
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'AZURE'
    ENABLED = TRUE
    AZURE_TENANT_ID = 'b2efcef3-8496-40b8-9de8-f135982f3461'
    STORAGE_ALLOWED_LOCATIONS = ('azure://stgthesis.blob.core.windows.net/cntthesis/');


-- ============================================================================
-- 2. NOTIFICATION INTEGRATION (shared, Azure only)
-- ============================================================================

CREATE OR REPLACE NOTIFICATION INTEGRATION NOTIF_INT_THESIS
    ENABLED = TRUE
    TYPE = QUEUE
    NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
    AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://stgthesis.queue.core.windows.net/snowpipe-queue'
    AZURE_TENANT_ID = 'b2efcef3-8496-40b8-9de8-f135982f3461';


-- ============================================================================
-- 3. FILE FORMAT (shared)
-- ============================================================================

CREATE OR REPLACE FILE FORMAT TEST_DB.TEST_SCHEMA.FILEFORMAT_THESIS
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    ESCAPE_UNENCLOSED_FIELD = 'NONE'
    TRIM_SPACE = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('#');

-- ============================================================================
-- 4. STAGE (shared, points to container ROOT)
-- ============================================================================

CREATE OR REPLACE STAGE TEST_DB.TEST_SCHEMA.EXT_STAGE_THESIS
    URL = 'azure://stgthesis.blob.core.windows.net/cntthesis/'
    STORAGE_INTEGRATION = AZURE_INT_THESIS
    FILE_FORMAT = (FORMAT_NAME = 'TEST_DB.TEST_SCHEMA.FILEFORMAT_THESIS');


-- ============================================================================
-- 5. TABLE: T_PRODUCTS
-- ============================================================================

CREATE OR REPLACE TABLE TEST_DB.TEST_SCHEMA.T_PRODUCTS (
    LOADED_AT                                          TIMESTAMP_NTZ(9),
    SOURCE_OF_RECORD                                   VARCHAR(16777216),
    EXTRACTED_AT                                       TIMESTAMP_NTZ(9),
    ROW_NUMBER                                         NUMBER(38,0),
    ROW_HASH                                           VARCHAR(16777216),
    KEY_HASH                                           VARCHAR(16777216),
    INDEX                                              VARCHAR(16777216),
    NAME                                               VARCHAR(16777216),
    PRICE                                              VARCHAR(16777216),
    CATEGORY                                           VARCHAR(16777216)
)
CHANGE_TRACKING = TRUE;


-- ============================================================================
-- 6. PIPE: PIPE_T_PRODUCTS
-- ============================================================================

CREATE OR REPLACE PIPE TEST_DB.TEST_SCHEMA.PIPE_T_PRODUCTS
    AUTO_INGEST = TRUE
    INTEGRATION = 'NOTIF_INT_THESIS'
AS
COPY INTO TEST_DB.TEST_SCHEMA.T_PRODUCTS
FROM (
    SELECT
        current_timestamp() loaded_at,
        METADATA$FILENAME source_of_record,
        NVL(to_timestamp_ltz(regexp_substr(metadata$filename, '\\d{14}'),
            'yyyymmddhh24miss'), CURRENT_TIMESTAMP) extracted_at,
        metadata$file_row_number row_number,
        md5(to_varchar(array_construct(T.$1, T.$2, T.$3, T.$4))) row_hash,
        md5(to_varchar(array_construct(T.$1))) key_hash,
        T.$1, T.$2, T.$3, T.$4
    FROM @TEST_DB.TEST_SCHEMA.EXT_STAGE_THESIS/
        (FILE_FORMAT => 'TEST_DB.TEST_SCHEMA.FILEFORMAT_THESIS',
         PATTERN => '(.*/)?products[.]csv') T
);


/*
================================================================================
  AZURE DATA FLOW
================================================================================

  Azure Blob Storage (azure://stgthesis.blob.core.windows.net/cntthesis/)
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
       ALTER PIPE TEST_DB.TEST_SCHEMA.PIPE_T_PRODUCTS REFRESH;

================================================================================
*/