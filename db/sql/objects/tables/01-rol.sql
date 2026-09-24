USE BSC;
GO

IF OBJECT_ID('dbo.Rol', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Rol (
        Id            INT            IDENTITY(1,1) NOT NULL,
        Nombre        NVARCHAR(50)   NOT NULL,
        Descripcion   NVARCHAR(200)  NULL,
        Activo        BIT            NOT NULL CONSTRAINT DF_Rol_Activo DEFAULT (1),

        CONSTRAINT PK_Rol PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT UQ_Rol_Nombre UNIQUE (Nombre)
    );
END;
GO

PRINT 'Rol table ready.';
GO