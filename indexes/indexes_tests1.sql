use u_szymocha;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT *
FROM dbo.ServiceUserDetails
WHERE DateOfRegistration BETWEEN '2025-01-01' AND '2025-01-22';

SELECT UserID, FirstName, LastName
FROM dbo.Users
WHERE DateOfBirth BETWEEN '1990-01-01' AND '2000-01-01';

SELECT UserID
FROM dbo.UserContact
WHERE Email = 'example@example.com';

SELECT SemesterID, StartDate, EndDate
FROM dbo.SemesterDetails
WHERE StudiesID = 123;

SELECT PaymentID, PaymentValue
FROM dbo.Payments
WHERE OrderID = 987;

SELECT OrderID, OrderDate
FROM dbo.Orders
WHERE UserID = 456;

Select MeetingID from dbo.StationaryMeeting
WHERE MeetingDate BETWEEN '2022-01-01' AND '2026-01-22';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- check
SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc AS IndexType,
    ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i
    ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 1
ORDER BY ips.avg_fragmentation_in_percent DESC;

DECLARE @TableName NVARCHAR(128);
DECLARE @IndexName NVARCHAR(128);
DECLARE @Fragmentation FLOAT;
DECLARE @Command NVARCHAR(MAX);


-- rebuild
DECLARE FragmentationCursor CURSOR FOR
SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent AS Fragmentation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ips
JOIN sys.indexes i
    ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 1000 
ORDER BY ips.avg_fragmentation_in_percent DESC;

OPEN FragmentationCursor;
FETCH NEXT FROM FragmentationCursor INTO @TableName, @IndexName, @Fragmentation;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Fragmentation < 30
    BEGIN
        SET @Command = 'ALTER INDEX [' + @IndexName + '] ON [' + @TableName + '] REORGANIZE;';
    END
    ELSE
    BEGIN
        SET @Command = 'ALTER INDEX [' + @IndexName + '] ON [' + @TableName + '] REBUILD;';
    END

    EXEC sp_executesql @Command;
    FETCH NEXT FROM FragmentationCursor INTO @TableName, @IndexName, @Fragmentation;
END;

CLOSE FragmentationCursor;
DEALLOCATE FragmentationCursor;
