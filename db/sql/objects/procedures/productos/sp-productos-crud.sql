USE BSC;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- sp_Productos_Listar: catalogo activo de productos
-- ============================================================
IF OBJECT_ID('dbo.sp_Productos_Listar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Productos_Listar;
GO

CREATE PROCEDURE dbo.sp_Productos_Listar
    @SoloActivos BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Clave,
        Nombre,
        Existencia,
        PrecioUnitario,
        Activo,
        FechaCreacion
    FROM dbo.Producto
    WHERE (@SoloActivos = 0 OR Activo = 1)
    ORDER BY Nombre;
END;
GO

-- ============================================================
-- sp_Productos_ObtenerPorId
-- ============================================================
IF OBJECT_ID('dbo.sp_Productos_ObtenerPorId', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Productos_ObtenerPorId;
GO

CREATE PROCEDURE dbo.sp_Productos_ObtenerPorId
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Clave,
        Nombre,
        Existencia,
        PrecioUnitario,
        Activo,
        FechaCreacion
    FROM dbo.Producto
    WHERE Id = @Id;
END;
GO

-- ============================================================
-- sp_Productos_ObtenerPorClave: chequeo de unicidad al crear/actualizar
-- ============================================================
IF OBJECT_ID('dbo.sp_Productos_ObtenerPorClave', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Productos_ObtenerPorClave;
GO

CREATE PROCEDURE dbo.sp_Productos_ObtenerPorClave
    @Clave NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Clave,
        Nombre,
        Existencia,
        PrecioUnitario,
        Activo,
        FechaCreacion
    FROM dbo.Producto
    WHERE Clave = @Clave;
END;
GO

-- ============================================================
-- sp_Productos_Insertar
-- ============================================================
IF OBJECT_ID('dbo.sp_Productos_Insertar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Productos_Insertar;
GO

CREATE PROCEDURE dbo.sp_Productos_Insertar
    @Clave NVARCHAR(20),
    @Nombre NVARCHAR(150),
    @Existencia INT,
    @PrecioUnitario DECIMAL(18, 2),
    @NuevoId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Producto (Clave, Nombre, Existencia, PrecioUnitario)
    VALUES (@Clave, @Nombre, @Existencia, @PrecioUnitario);

    SET @NuevoId = SCOPE_IDENTITY();
END;
GO

-- ============================================================
-- sp_Productos_Actualizar
-- ============================================================
IF OBJECT_ID('dbo.sp_Productos_Actualizar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Productos_Actualizar;
GO

CREATE PROCEDURE dbo.sp_Productos_Actualizar
    @Id INT,
    @Clave NVARCHAR(20),
    @Nombre NVARCHAR(150),
    @Existencia INT,
    @PrecioUnitario DECIMAL(18, 2),
    @Activo BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Producto
    SET Clave = @Clave,
        Nombre = @Nombre,
        Existencia = @Existencia,
        PrecioUnitario = @PrecioUnitario,
        Activo = @Activo
    WHERE Id = @Id;
END;
GO

-- ============================================================
-- sp_Productos_ObtenerExistencias: reporte rapido para Administrativo
-- Reutiliza la vista vw_Productos_Existencias con campos extra del join.
-- ============================================================
IF OBJECT_ID('dbo.sp_Productos_ObtenerExistencias', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Productos_ObtenerExistencias;
GO

CREATE PROCEDURE dbo.sp_Productos_ObtenerExistencias
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Clave,
        Nombre,
        Existencia,
        PrecioUnitario,
        PrecioUnitario * Existencia AS ValorInventario,
        EstatusStock
    FROM dbo.vw_Productos_Existencias
    ORDER BY Nombre;
END;
GO

PRINT 'Productos CRUD procedures ready.';
GO