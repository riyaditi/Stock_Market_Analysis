select DB_NAME()

USE stock_analytics;
GO

CREATE SCHEMA staging;
GO

CREATE SCHEMA dim;
GO

CREATE SCHEMA fact;
GO

SELECT name 
FROM sys.schemas
WHERE name = 'fact';