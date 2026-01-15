/* ============================================================
   STEP 1 – POPULATE DATE DIMENSION FROM PRICE DATA
   ============================================================ */

-- Insert one row per unique calendar date from cleaned timestamps
INSERT INTO dim.dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day,
    day_name,
    is_weekend
)
SELECT DISTINCT
    CONVERT(INT, FORMAT(ts_dt, 'yyyyMMdd')) AS date_key,   -- Surrogate key YYYYMMDD
    CAST(ts_dt AS DATE) AS full_date,                     -- Actual date
    YEAR(ts_dt),
    DATEPART(QUARTER, ts_dt),
    MONTH(ts_dt),
    DATENAME(MONTH, ts_dt),
    DAY(ts_dt),
    DATENAME(WEEKDAY, ts_dt),
    CASE 
        WHEN DATENAME(WEEKDAY, ts_dt) IN ('Saturday','Sunday') THEN 1 
        ELSE 0 
    END                                                   -- Weekend flag
FROM staging.shares;


/* ============================================================
   STEP 2 – VALIDATE DATE DIMENSION STRUCTURE
   ============================================================ */

-- Check dim_date columns and datatypes
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dim'
  AND TABLE_NAME = 'dim_date';


-- Add descriptive columns if not present
ALTER TABLE dim.dim_date ADD
    quarter TINYINT,
    month_name VARCHAR(15),
    day_name VARCHAR(15);


/* ============================================================
   STEP 3 – VERIFY DATE DATA QUALITY
   ============================================================ */

-- View sample records
SELECT TOP 10 * FROM dim.dim_date;

-- Ensure one row per date (no duplicates)
SELECT full_date, COUNT(*) AS cnt
FROM dim.dim_date
GROUP BY full_date
ORDER BY full_date;


/* ============================================================
   STEP 4 – POPULATE TIME DIMENSION FROM TRADE DATA
   ============================================================ */

-- Insert any trade times not yet in time dimension
INSERT INTO dim.dim_time (
    time_key,
    hour,
    minute,
    second,
    time_bucket
)
SELECT DISTINCT
    DATEPART(HOUR, t.ts) * 10000
      + DATEPART(MINUTE, t.ts) * 100
      + DATEPART(SECOND, t.ts),
    DATEPART(HOUR, t.ts),
    DATEPART(MINUTE, t.ts),
    DATEPART(SECOND, t.ts),
    FORMAT(t.ts, 'HH:mm:ss')
FROM staging.share_trade t
LEFT JOIN dim.dim_time d
    ON d.time_key =
       DATEPART(HOUR, t.ts) * 10000
     + DATEPART(MINUTE, t.ts) * 100
     + DATEPART(SECOND, t.ts)
WHERE d.time_key IS NULL
  AND t.ts IS NOT NULL;


/* ============================================================
   STEP 5 – POPULATE SECURITY (ISIN) DIMENSION
   ============================================================ */

-- Insert any missing ISINs from trade data
INSERT INTO dim.dim_security (isin)
SELECT DISTINCT s.isin
FROM staging.share_trade s
LEFT JOIN dim.dim_security d
    ON s.isin = d.isin
WHERE d.isin IS NULL;


/* ============================================================
   STEP 6 – LOAD FACT_PRICE (MARKET PRICES)
   ============================================================ */

-- Each row = one market price at a given date & time
INSERT INTO fact.fact_price (
    isin,
    date_key,
    time_key,
    price
)
SELECT
    s.ts,                                                -- ISIN
    CONVERT(INT, FORMAT(s.ts_dt, 'yyyyMMdd')),           -- Date key
    DATEPART(HOUR, s.ts_dt) * 10000
      + DATEPART(MINUTE, s.ts_dt) * 100
      + DATEPART(SECOND, s.ts_dt),                       -- Time key
    s.price                                              -- Price
FROM staging.shares s;


/* ============================================================
   STEP 7 – CLEAN & REBUILD SOURCE DIMENSION
   ============================================================ */

-- Remove existing fact rows (to allow dimension rebuild)
DELETE FROM fact.fact_trade;

-- Remove old corrupted source dimension
DELETE FROM dim.dim_source;

-- Insert clean source categories
WITH cleaned AS (
    SELECT
        CASE
            WHEN data LIKE '%source=HL%' OR data LIKE '%source:HL%' THEN 'HL'
            WHEN data LIKE '%ice=%' THEN 'ICE'
            ELSE 'UNKNOWN'
        END AS source
    FROM staging.share_trade
)
INSERT INTO dim.dim_source (source_name)
SELECT DISTINCT source
FROM cleaned;

-- Validate source dimension
SELECT * FROM dim.dim_source;


/* ============================================================
   STEP 8 – LOAD FACT_TRADE (TRADING TRANSACTIONS)
   ============================================================ */

-- Insert all trades into fact table using cleaned dimensions
INSERT INTO fact.fact_trade (
    isin,
    date_key,
    time_key,
    action,
    volume,
    quantity,
    source_key
)
SELECT
    t.isin,

    -- Use Unknown date (0) if timestamp missing
    CASE WHEN t.ts IS NULL THEN 0
         ELSE CONVERT(INT, FORMAT(t.ts, 'yyyyMMdd'))
    END,

    -- Use Unknown time (0) if timestamp missing
    CASE WHEN t.ts IS NULL THEN 0
         ELSE DATEPART(HOUR, t.ts) * 10000
            + DATEPART(MINUTE, t.ts) * 100
            + DATEPART(SECOND, t.ts)
    END,

    t.action,
    t.vol,

    -- Safely convert quantity from semi-structured text
    CAST(TRY_CAST(
        SUBSTRING(t.data, CHARINDEX('quantity=', t.data) + 9,
                  CHARINDEX(',', t.data, CHARINDEX('quantity=', t.data))
                  - CHARINDEX('quantity=', t.data) - 9
        ) AS FLOAT) AS INT
    ),

    s.source_key
FROM staging.share_trade t
JOIN dim.dim_source s
  ON s.source_name =
     CASE
         WHEN t.data LIKE '%source=HL%' OR t.data LIKE '%source:HL%' THEN 'HL'
         WHEN t.data LIKE '%ice=%' THEN 'ICE'
         ELSE 'UNKNOWN'
     END;


/* ============================================================
   STEP 9 – FINAL VALIDATION
   ============================================================ */

-- Total trades loaded
SELECT COUNT(*) AS total_trades FROM fact.fact_trade;

-- Trades with missing date or time
SELECT COUNT(*) AS unknown_datetime
FROM fact.fact_trade
WHERE date_key = 0 OR time_key = 0;

-- Sample rows
SELECT TOP 10 * FROM fact.fact_trade;
