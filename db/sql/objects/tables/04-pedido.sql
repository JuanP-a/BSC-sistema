USE BSC;
GO

IF OBJECT_ID('dbo.Pedido', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Pedido (
        Id             INT             IDENTITY(1,1) NOT NULL,
        UsuarioId      INT             NOT NULL,
        ClienteNombre  NVARCHAR(150)   NOT NULL,
        Total          DECIMAL(18, 2)  NOT NULL CONSTRAINT DF_Pedido_Total DEFAULT (0),
        Estatus        NVARCHAR(20)    NOT NULL CONSTRAINT DF_Pedido_Estatus DEFAULT ('Pendiente'),
        FechaCreacion  DATETIME2       NOT NULL CONSTRAINT DF_Pedido_FechaCreacion DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Pedido PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_Pedido_Usuario FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario(Id),
        CONSTRAINT CK_Pedido_Total_NonNeg CHECK (Total >= 0),
        CONSTRAINT CK_Pedido_Estatus_Validos CHECK (Estatus IN ('Pendiente', 'EnProceso', 'Completado', 'Cancelado'))
    );
END;
GO

PRINT 'Pedido table ready.';
GO