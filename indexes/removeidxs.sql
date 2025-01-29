use u_szymocha
SELECT 
    sch.name AS SchemaName,
    t.name AS TableName,
    ix.name AS IndexName,
    ix.type_desc AS IndexType
FROM 
    sys.indexes ix
INNER JOIN 
    sys.tables t ON ix.object_id = t.object_id
INNER JOIN 
    sys.schemas sch ON t.schema_id = sch.schema_id
WHERE 
    ix.is_primary_key = 0
    AND ix.is_unique_constraint = 0
    AND ix.type_desc IN ('CLUSTERED', 'NONCLUSTERED')
    AND ix.name IS NOT NULL
ORDER BY 
    sch.name, t.name, ix.name;

DECLARE @DropIndexCommands NVARCHAR(MAX) = N'';

SELECT 
    @DropIndexCommands += 
        'DROP INDEX [' + ix.name + '] ON [' + sch.name + '].[' + t.name + '];' + CHAR(13)
FROM 
    sys.indexes ix
INNER JOIN 
    sys.tables t ON ix.object_id = t.object_id
INNER JOIN 
    sys.schemas sch ON t.schema_id = sch.schema_id
WHERE 
    ix.is_primary_key = 0
    AND ix.is_unique_constraint = 0
    AND ix.type_desc IN ('CLUSTERED', 'NONCLUSTERED')
    AND ix.name IS NOT NULL;

PRINT @DropIndexCommands;

EXEC sp_executesql @DropIndexCommands;

use u_szymocha
SELECT 
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM 
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN 
    sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE 
    ips.avg_fragmentation_in_percent >= 0 -- >=0
ORDER BY 
    avg_fragmentation_in_percent DESC;

DECLARE @RebuildIndexCommands NVARCHAR(MAX) = N'';
SELECT 
    @RebuildIndexCommands += 
        'ALTER INDEX [' + i.name + '] ON [' + OBJECT_NAME(ips.object_id) + '] REBUILD;' + CHAR(13)
FROM 
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN 
    sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE 
    ips.avg_fragmentation_in_percent > 30;

PRINT @RebuildIndexCommands;

EXEC sp_executesql @RebuildIndexCommands;

select * from Rooms
