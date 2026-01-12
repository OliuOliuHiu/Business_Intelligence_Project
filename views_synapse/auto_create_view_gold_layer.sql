USE HRManagement;
GO

CREATE OR ALTER PROC CreateSQLServerlessView_Gold @ViewName NVARCHAR(100)
AS
BEGIN
    DECLARE @FullViewName NVARCHAR(256);
    DECLARE @statement NVARCHAR(MAX);

    -- Ensure schema 'gold' exists
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
    BEGIN
        EXEC('CREATE SCHEMA gold;');
    END

    -- Define full view name
    SET @FullViewName = 'gold.' + QUOTENAME(@ViewName);

    -- Drop view if it already exists
    IF EXISTS (SELECT * FROM sys.views WHERE name = @ViewName AND SCHEMA_ID = SCHEMA_ID('gold'))
    BEGIN
        SET @statement = N'DROP VIEW ' + @FullViewName;
        EXEC sp_executesql @statement;
    END

    -- Create new view to read from Delta table in ADLS
    SET @statement = N'CREATE VIEW ' + @FullViewName + ' AS
        SELECT *
        FROM
            OPENROWSET(
                BULK ''https://hieumk224161813.blob.core.windows.net/testsynapsehieum/gold/' + @ViewName + '/'',
                FORMAT = ''DELTA''
            ) AS [result]';

    EXEC sp_executesql @statement;
END;
GO





