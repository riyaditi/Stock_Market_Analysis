SELECT TOP 5 ts
FROM staging.shares;

ALTER TABLE staging.shares
ADD ts_dt DATETIME2(0);

UPDATE staging.shares
SET ts_dt = TRY_CONVERT(DATETIME2(0), ts, 103);

SELECT COUNT(*) AS null_count
FROM staging.shares
WHERE ts_dt IS NULL;

SELECT TOP 10 ts
FROM staging.shares
WHERE ts_dt IS NULL;

UPDATE staging.shares
SET ts_dt = COALESCE(
    TRY_CONVERT(DATETIME2(0), ts, 103), -- dd/MM/yyyy HH:mm
    TRY_CONVERT(DATETIME2(0), ts, 101)  -- MM/dd/yyyy HH:mm
);

SELECT TOP 10 ts, ts_dt
FROM staging.shares
ORDER BY ts_dt;

