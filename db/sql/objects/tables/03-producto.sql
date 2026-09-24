USE BSC;
GO

IF OBJECT_ID('dbo.Producto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Producto (
        Id              INT             IDENTITY(1,1) NOT NULL,
        Clave           NVARCHAR(20)    NOT NULL,
        Nombre          NVARCHAR(150)   NOT NULL,
        Existencia      INT             NOT NULL CONSTRAINT DF_Producto_Existencia DEFAULT (0),
        PrecioUnitario  DECIMAL(18, 2)  NOT NULL CONSTRAINT DF_Producto_PrecioUnitario DEFAULT (0),
        Activo          BIT             NOT NULL CONSTRAINT DF_Producto_Activo DEFAULT (1),
        FechaCreacion   DATETIME2       NOT NULL CONSTRAINT DF_Producto_FechaCreacion DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Producto PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT UQ_Producto_Clave UNIQUE (Clave),
        CONSTRAINT CK_Producto_Existencia_NonNeg CHECK (Existencia >= 0),
        CONSTRAINT CK_Producto_PrecioUnitario_NonNeg CHECK (PrecioUnitario >= 0)
    );
END;
GO

PRINT 'Producto table ready.';
GO