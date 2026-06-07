/*
================================================================================
  TEST_DB - CACHE_TEST SNOWPIPE INGESTION (AZURE)
================================================================================
  Cloud:      Azure Blob Storage
  Database:   TEST_DB
  Schema:     RAW
  Generated:  2026-06-07T21:52:05Z

  Components (6 - Azure pattern):
    1. Storage Integration:      AZURE_INT_CACHE_TEST
    2. Notification Integration: NOTIF_INT_CACHE_TEST  <- AZURE ONLY
    3. File Format:              TEST_DB.RAW.FILEFORMAT_CACHE_TEST
    4. Stage:                    TEST_DB.RAW.EXT_STAGE_CACHE_TEST
    5. Table:                    TEST_DB.RAW.T_CACHE_TEST
    6. Pipe:                     TEST_DB.RAW.PIPE_T_CACHE_TEST
================================================================================
*/


-- ============================================================================
-- 1. STORAGE INTEGRATION
-- ============================================================================
-- Connects Snowflake to Azure Blob Storage via service principal.

CREATE OR REPLACE STORAGE INTEGRATION AZURE_INT_CACHE_TEST
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'AZURE'
    ENABLED = TRUE
    AZURE_TENANT_ID = '12345678-1234-1234-1234-123456789012'
    STORAGE_ALLOWED_LOCATIONS = ('azure://test.blob.core.windows.net/data/');


-- ============================================================================
-- 2. NOTIFICATION INTEGRATION (AZURE ONLY)
-- ============================================================================
-- Required for Azure auto-ingest. Receives events from Azure Storage Queue.

CREATE OR REPLACE NOTIFICATION INTEGRATION NOTIF_INT_CACHE_TEST
    ENABLED = TRUE
    TYPE = QUEUE
    NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
    AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://test.queue.core.windows.net/q'
    AZURE_TENANT_ID = '12345678-1234-1234-1234-123456789012';


-- ============================================================================
-- 3. FILE FORMAT
-- ============================================================================

CREATE OR REPLACE FILE FORMAT TEST_DB.RAW.FILEFORMAT_CACHE_TEST
    TYPE = 'CSV'
    FIELD_DELIMITER = '|'
    SKIP_HEADER = 1
    ESCAPE_UNENCLOSED_FIELD = 'NONE'
    TRIM_SPACE = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('#');


-- ============================================================================
-- 4. STAGE
-- ============================================================================

CREATE OR REPLACE STAGE TEST_DB.RAW.EXT_STAGE_CACHE_TEST
    URL = 'azure://test.blob.core.windows.net/data/'
    STORAGE_INTEGRATION = AZURE_INT_CACHE_TEST
    FILE_FORMAT = (FORMAT_NAME = 'TEST_DB.RAW.FILEFORMAT_CACHE_TEST');


-- ============================================================================
-- 5. TABLE (7 columns)
-- ============================================================================

CREATE OR REPLACE TABLE TEST_DB.RAW.T_CACHE_TEST (
    LOADED_AT                                          TIMESTAMP_NTZ(9),
    SOURCE_OF_RECORD                                   VARCHAR(16777216),
    EXTRACTED_AT                                       TIMESTAMP_NTZ(9),
    ROW_NUMBER                                         NUMBER(38,0),
    ROW_HASH                                           VARCHAR(16777216),
    KEY_HASH                                           VARCHAR(16777216),
    ID                                                 VARCHAR(16777216)
)
CHANGE_TRACKING = TRUE;


-- ============================================================================
-- 6. PIPE (references NOTIFICATION INTEGRATION - Azure requirement)
-- ============================================================================

CREATE OR REPLACE PIPE TEST_DB.RAW.PIPE_T_CACHE_TEST
    AUTO_INGEST = TRUE
    INTEGRATION = 'NOTIF_INT_CACHE_TEST'
AS
COPY INTO TEST_DB.RAW.T_CACHE_TEST
FROM (
    SELECT
        current_timestamp() loaded_at,
        METADATA$FILENAME source_of_record,
        NVL(to_timestamp_ltz(regexp_substr(metadata$filename, '\\d{14}'),
            'yyyymmddhh24miss'), CURRENT_TIMESTAMP) extracted_at,
        metadata$file_row_number row_number,
        md5(to_varchar(array_construct(T.$1))) row_hash,
        md5(to_varchar(array_construct(T.$1))) key_hash,
        T.$1, T.$2, T.$3, T.$4, T.$5, T.$6, T.$7
    FROM @TEST_DB.RAW.EXT_STAGE_CACHE_TEST/
        (FILE_FORMAT => 'TEST_DB.RAW.FILEFORMAT_CACHE_TEST') T
);


/*
================================================================================
  AZURE DATA FLOW
================================================================================

  Azure Blob Storage (azure://test.blob.core.windows.net/data/)
      |
      | (Event Grid -> Storage Queue)
      v
  Notification Integration: NOTIF_INT_CACHE_TEST
      |
      v
  Storage Integration: AZURE_INT_CACHE_TEST
      |
      v
  External Stage: EXT_STAGE_CACHE_TEST
      |
      v
  Pipe: PIPE_T_CACHE_TEST --> Table: T_CACHE_TEST

================================================================================
  POST-CREATION STEPS
================================================================================

  1. After creating storage integration:
       DESC INTEGRATION AZURE_INT_CACHE_TEST;
     Copy AZURE_CONSENT_URL, open in browser, grant consent.

  2. After creating notification integration:
       DESC INTEGRATION NOTIF_INT_CACHE_TEST;
     Copy AZURE_CONSENT_URL if shown, grant consent.

  3. Configure Event Grid subscription on the Azure container
     to send events to the Storage Queue.

  4. Test with:
       ALTER PIPE TEST_DB.RAW.PIPE_T_CACHE_TEST REFRESH;

================================================================================
*/