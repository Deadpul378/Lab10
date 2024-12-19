-- Создаём триггер предотвращения изменения таблицы Driver
CREATE TRIGGER trg_PreventAlterDriver
ON DATABASE
FOR ALTER_TABLE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @data XML = EVENTDATA();

    DECLARE @ObjectName NVARCHAR(256) = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(256)');

    IF @ObjectName = 'Driver'
    BEGIN
        RAISERROR('Изменение структуры таблицы Driver запрещено.', 16, 1);
        ROLLBACK;
    END
END
GO

-- Затем создаём триггер предотвращения удаления таблиц
CREATE TRIGGER trg_PreventDropTables
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    RAISERROR('Удаление таблиц запрещено.', 16, 1);
    ROLLBACK;
END
GO

-- Наконец, создаём триггер логирования ALTER TABLE
CREATE TRIGGER trg_LogALTERTable
ON DATABASE
FOR ALTER_TABLE
AS
BEGIN
    DECLARE @data XML = EVENTDATA();
    INSERT INTO DDL_Log (EventType, ObjectName, EventTime)
    VALUES (
        @data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)'),
        GETDATE()
    );
END
GO	
