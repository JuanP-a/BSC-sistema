USE BSC;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- sp_Roles_Listar: catalogo de roles activos (dropdowns)
-- ============================================================
IF OBJECT_ID('dbo.sp_Roles_Listar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Roles_Listar;
GO

CREATE PROCEDURE dbo.sp_Roles_Listar
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Nombre, Descripcion, Activo
    FROM dbo.Rol
    WHERE Activo = 1
    ORDER BY Nombre;
END;
GO

-- ============================================================
-- sp_Usuarios_Listar: catalogo completo de usuarios (admin)
-- ============================================================
IF OBJECT_ID('dbo.sp_Usuarios_Listar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Usuarios_Listar;
GO

CREATE PROCEDURE dbo.sp_Usuarios_Listar
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.Id,
        u.NombreUsuario,
        u.NombreCompleto,
        u.Correo,
        u.RolId,
        r.Nombre AS RolNombre,
        u.Activo,
        u.FechaCreacion
    FROM dbo.Usuario AS u
    INNER JOIN dbo.Rol AS r ON u.RolId = r.Id
    ORDER BY u.NombreCompleto;
END;
GO

-- ============================================================
-- sp_Usuarios_ObtenerPorId
-- ============================================================
IF OBJECT_ID('dbo.sp_Usuarios_ObtenerPorId', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Usuarios_ObtenerPorId;
GO

CREATE PROCEDURE dbo.sp_Usuarios_ObtenerPorId
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.Id,
        u.NombreUsuario,
        u.NombreCompleto,
        u.Correo,
        u.RolId,
        r.Nombre AS RolNombre,
        u.Activo,
        u.FechaCreacion
    FROM dbo.Usuario AS u
    INNER JOIN dbo.Rol AS r ON u.RolId = r.Id
    WHERE u.Id = @Id;
END;
GO

-- ============================================================
-- sp_Usuarios_ObtenerPorNombre
-- ============================================================
IF OBJECT_ID('dbo.sp_Usuarios_ObtenerPorNombre', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Usuarios_ObtenerPorNombre;
GO

CREATE PROCEDURE dbo.sp_Usuarios_ObtenerPorNombre
    @NombreUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.Id,
        u.NombreUsuario,
        u.NombreCompleto,
        u.Correo,
        u.RolId,
        r.Nombre AS RolNombre,
        u.Activo,
        u.FechaCreacion
    FROM dbo.Usuario AS u
    INNER JOIN dbo.Rol AS r ON u.RolId = r.Id
    WHERE u.NombreUsuario = @NombreUsuario;
END;
GO

-- ============================================================
-- sp_Usuarios_Insertar: recibe hash pre-computado en Business
-- ============================================================
IF OBJECT_ID('dbo.sp_Usuarios_Insertar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Usuarios_Insertar;
GO

CREATE PROCEDURE dbo.sp_Usuarios_Insertar
    @NombreUsuario NVARCHAR(50),
    @ContrasenaHash NVARCHAR(255),
    @NombreCompleto NVARCHAR(150),
    @Correo NVARCHAR(150),
    @RolId INT,
    @NuevoId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Usuario (NombreUsuario, ContrasenaHash, NombreCompleto, Correo, RolId)
    VALUES (@NombreUsuario, @ContrasenaHash, @NombreCompleto, @Correo, @RolId);

    SET @NuevoId = SCOPE_IDENTITY();
END;
GO

-- ============================================================
-- sp_Usuarios_Actualizar: si @ContrasenaHash IS NULL, conserva la actual
-- ============================================================
IF OBJECT_ID('dbo.sp_Usuarios_Actualizar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Usuarios_Actualizar;
GO

CREATE PROCEDURE dbo.sp_Usuarios_Actualizar
    @Id INT,
    @NombreCompleto NVARCHAR(150),
    @Correo NVARCHAR(150),
    @RolId INT,
    @Activo BIT,
    @ContrasenaHash NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ContrasenaHash IS NULL
    BEGIN
        UPDATE dbo.Usuario
        SET NombreCompleto = @NombreCompleto,
            Correo = @Correo,
            RolId = @RolId,
            Activo = @Activo
        WHERE Id = @Id;
    END
    ELSE
    BEGIN
        UPDATE dbo.Usuario
        SET NombreCompleto = @NombreCompleto,
            Correo = @Correo,
            RolId = @RolId,
            Activo = @Activo,
            ContrasenaHash = @ContrasenaHash
        WHERE Id = @Id;
    END
END;
GO

PRINT 'Usuarios + Roles procedures ready.';
GO