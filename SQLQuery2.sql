ALTER TRIGGER trg_AfterInsert_Patient
ON Patient
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Patient_Log (ID_Patient, Action, Action_Time)
    SELECT ID_Patient, 'INSERT', GETDATE()
    FROM inserted;
END

GO

ALTER TRIGGER trg_InsteadOfUpdate_Driver
ON Driver
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Driver
    SET Name = inserted.Name,
        Patronymic = inserted.Patronymic,
        Ambulance = inserted.Ambulance
    FROM Driver
    INNER JOIN inserted ON Driver.ID_Driver = inserted.ID_Driver;
END

GO

CREATE TRIGGER trg_InsteadOfDelete_Diagnosis
ON Diagnosis
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    
    IF EXISTS (
        SELECT 1
        FROM Call
        WHERE ID_Diagnosis IN (SELECT ID_Diagnosis FROM deleted)
    )
    BEGIN
        RAISERROR('Ќевозможно удалить диагноз, который используетс€ в вызовах.', 16, 1);
        RETURN;
    END

    
    IF EXISTS (
        SELECT 1
        FROM Patient
        WHERE ID_Diagnosis IN (SELECT ID_Diagnosis FROM deleted)
    )
    BEGIN
        RAISERROR('Ќевозможно удалить диагноз, который используетс€ пациентами.', 16, 1);
        RETURN;
    END
    DELETE FROM Diagnosis
    WHERE ID_Diagnosis IN (SELECT ID_Diagnosis FROM deleted);
END 