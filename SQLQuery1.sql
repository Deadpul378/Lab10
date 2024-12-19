ALTER TABLE Driver
ADD CONSTRAINT CHK_Driver_Surname_Length CHECK (LEN(Surname) <= 100);

GO

ALTER TRIGGER trg_Ambulance_Driver_Assignment
ON Ambulance
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT ID_Driver
        FROM inserted
        GROUP BY ID_Driver
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR('Водитель должен быть назначен только на одну бригаду.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

GO

ALTER TABLE Brigade
ADD CONSTRAINT CHK_Brigade_Name_Length CHECK (LEN(Name) <= 50);

GO

ALTER TRIGGER trg_Brigade_Roles_Validation
ON Brigade
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Doctor IS NULL OR Nurse IS NULL OR Orderly IS NULL
    )
    BEGIN
        RAISERROR('Бригада должна включать доктора, медсестру и помошника.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

GO

ALTER TABLE Ambulance
ADD CONSTRAINT CHK_Ambulance_Type_Length CHECK (LEN(Type) <= 50);

GO

ALTER TRIGGER trg_Call_Associations
ON Call
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE ID_Ambulance IS NULL
           OR ID_Brigade IS NULL
           OR ID_Diagnosis IS NULL
           OR ID_Driver IS NULL
           OR ID_Patient IS NULL
    )
    BEGIN
        RAISERROR('Каждый вызов должен быть связан с машиной, бригадой, диагнозом, водителем и пациентом.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

GO

ALTER TABLE Patient
ADD CONSTRAINT CHK_Patient_Surname_Length CHECK (LEN(Surname) <= 100);

GO

ALTER TABLE Patient
ADD CONSTRAINT CHK_Patient_Age_Validation CHECK (Age > 0 AND Age <= 120);

GO

ALTER TABLE Diagnosis
ADD CONSTRAINT CHK_Diagnosis_Preliminary_Length CHECK (LEN(Preliminary) <= 255);

GO

ALTER TRIGGER trg_Call_Arrival_Time
ON Call
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Arrival_Time > GETDATE()
    )
    BEGIN
        RAISERROR('Время прибытия вызова не может быть позже текущего времени системы.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
