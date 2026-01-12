USE HRManagement
GO

CREATE OR ALTER PROC CreateSQLServerlessView_Silver @ViewName NVARCHAR(100)
AS
BEGIN
    DECLARE @FullViewName NVARCHAR(256);
    DECLARE @statement NVARCHAR(MAX);

    -- Kiểm tra schema `silver` có tồn tại không
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
    BEGIN
        EXEC('CREATE SCHEMA silver;');
    END

    -- Xác định tên đầy đủ của view
    SET @FullViewName = 'silver.' + QUOTENAME(@ViewName);

    -- Kiểm tra nếu view đã tồn tại, thì xóa trước khi tạo lại
    IF EXISTS (SELECT * FROM sys.views WHERE name = @ViewName AND SCHEMA_ID = SCHEMA_ID('silver'))
    BEGIN
        SET @statement = N'DROP VIEW ' + @FullViewName;
        EXEC sp_executesql @statement;
    END

    -- Tạo view mới
    SET @statement = N'CREATE VIEW ' + @FullViewName + ' AS
        SELECT *
        FROM
            OPENROWSET(
                BULK ''https://hieumk224161813.blob.core.windows.net/testsynapsehieum/silver/' + @ViewName + '/'',
                FORMAT = ''PARQUET''
            ) AS [result]';

    EXEC sp_executesql @statement;
END
GO

