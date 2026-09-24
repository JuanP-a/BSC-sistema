USE BSC;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- sp_Usuarios_Autenticar: retorna usuario + rol para validacion de login
-- La verificacion del hash de contrasena ocurre en BSC.Business
-- (BCrypt) — la SP solo expone los datos necesarios.
-- ============================================================
IF OBJECT_ID('dbo.sp_Usuarios_Autenticar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Usuarios_Autenticar;
GO

CREATE PROCEDURE dbo.sp_Usuarios_Autenticar
    @NombreUsuario NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.Id,
        u.NombreUsuario,
        u.ContrasenaHash,
        u.NombreCompleto,
        u.Correo,
        u.RolId,
        r.Nombre AS RolNombre,
        u.Activo,
        u.FechaCreacion
    FROM dbo.Usuario AS u
    INNER JOIN dbo.Rol AS r ON u.RolId = r.Id
    WHERE u.NombreUsuario = @NombreUsuario
      AND u.Activo = 1;
END;
GO

PRINT 'sp_Usuarios_Autenticar ready.';
GO