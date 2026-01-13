CREATE TABLE staging.shares (
	[ID] BIGINT NULL, 
	[TS] VARCHAR(max) NULL, 
	[PRICE] BIGINT NULL
)

CREATE TABLE staging.share_lookup (
	[ID] BIGINT NULL, 
	[ISIN] VARCHAR(max) NULL
)

CREATE TABLE staging.share_trade (
    TS      DATETIME2(0)       NULL,
    MS      INT                NULL,
    ISIN    VARCHAR(20)        NULL,
    ACTION  VARCHAR(10)        NULL,
    VOL     DECIMAL(18,2)      NULL,
    DATA    NVARCHAR(MAX)      NULL
);

CREATE TABLE dim.dim_security (
    isin VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(100)
);


CREATE TABLE dim.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT,
    is_weekend bit
);

CREATE TABLE dim.dim_time (
    time_key INT PRIMARY KEY,
    hour INT,
    minute INT,
    second INT,
    time_bucket VARCHAR(20)
);

CREATE TABLE dim.dim_source (
    source_key INT IDENTITY(1,1) PRIMARY KEY,
    source_name VARCHAR(50)
);



CREATE TABLE fact.fact_price (
    price_id INT IDENTITY(1,1) PRIMARY KEY,
    isin VARCHAR(20),
    date_key INT,
    time_key INT,
    price DECIMAL(10,2),
    FOREIGN KEY (isin) REFERENCES dim.dim_security(isin),
    FOREIGN KEY (date_key) REFERENCES dim.dim_date(date_key),
    FOREIGN KEY (time_key) REFERENCES dim.dim_time(time_key)
);


CREATE TABLE fact.fact_trade (
    trade_id INT IDENTITY(1,1) PRIMARY KEY,
    isin VARCHAR(20),
    date_key INT,
    time_key INT,
    action VARCHAR(10),
    volume INT,
    quantity INT,
    source_key INT,
    FOREIGN KEY (isin) REFERENCES dim.dim_security(isin),
    FOREIGN KEY (date_key) REFERENCES dim.dim_date(date_key),
    FOREIGN KEY (time_key) REFERENCES dim.dim_time(time_key),
    FOREIGN KEY (source_key) REFERENCES dim.dim_source(source_key)
);
