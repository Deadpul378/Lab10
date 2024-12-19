CREATE TRIGGER trg_LogonAudit
ON ALL SERVER
FOR LOGON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LoginName NVARCHAR(100);
    DECLARE @HostName NVARCHAR(100);
    DECLARE @ProgramName NVARCHAR(100);
    DECLARE @LoginTime DATETIME;
    DECLARE @ClientIP NVARCHAR(45);

    SET @LoginName = ORIGINAL_LOGIN();

    
    SET @HostName = HOST_NAME();
    SET @ProgramName = PROGRAM_NAME();

    SET @LoginTime = GETDATE();

    BEGIN TRY
        DECLARE @SessionID INT = @@SPID;
        SELECT @ClientIP = client_net_address
        FROM sys.dm_exec_connections
        WHERE session_id = @SessionID;
    END TRY
    BEGIN CATCH
        SET @ClientIP = NULL;
    END CATCH

    BEGIN TRY
        INSERT INTO master.dbo.LogonAudit (LoginName, HostName, ProgramName, LoginTime, ClientIPAddress)
        VALUES (@LoginName, @HostName, @ProgramName, @LoginTime, @ClientIP);
    END TRY
    BEGIN CATCH
        
    END CATCH
END
