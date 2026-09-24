USE BSC;
GO

IF OBJECT_ID('dbo.Usuario', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Usuario (
        Id               INT            IDENTITY(1,1) NOT NULL,
        NombreUsuario    NVARCHAR(50)   NOT NULL,
        ContrasenaHash   NVARCHAR(255)  NOT NULL,
        NombreCompleto   NVARCHAR(150)  NOT NULL,
        Correo           NVARCHAR(150)  NULL,
        RolId            INT            NOT NULL,
        Activo           BIT            NOT NULL CONSTRAINT DF_Usuario_Activo DEFAULT (1),
        FechaCreacion    DATETIME2      NOT NULL CONSTRAINT DF_Usuario_FechaCreacion DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Usuario PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT UQ_Usuario_NombreUsuario UNIQUE (NombreUsuario),
        CONSTRAINT FK_Usuario_Rol FOREIGN KEY (RolId) REFERENCES dbo.Rol(Id),
        CONSTRAINT CK_Usuario_NombreUsuario_Length CHECK (LEN(NombreUsuario) >= 4)
    );
END;
GO

PRINT 'Usuario table ready.';
GO