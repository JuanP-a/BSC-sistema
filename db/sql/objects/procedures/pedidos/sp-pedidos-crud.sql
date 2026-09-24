USE BSC;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- sp_Pedidos_Listar: catalogo de pedidos con vendedor (admin)
-- ============================================================
IF OBJECT_ID('dbo.sp_Pedidos_Listar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Pedidos_Listar;
GO

CREATE PROCEDURE dbo.sp_Pedidos_Listar
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pe.Id,
        pe.ClienteNombre,
        pe.Total,
        pe.Estatus,
        pe.FechaCreacion,
        u.NombreUsuario AS Vendedor,
        r.Nombre AS RolVendedor
    FROM dbo.Pedido AS pe
    INNER JOIN dbo.Usuario AS u ON pe.UsuarioId = u.Id
    INNER JOIN dbo.Rol AS r ON u.RolId = r.Id
    ORDER BY pe.FechaCreacion DESC;
END;
GO

-- ============================================================
-- sp_Pedidos_ObtenerPorId: pedido + sus detalles + productos
-- ============================================================
IF OBJECT_ID('dbo.sp_Pedidos_ObtenerPorId', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Pedidos_ObtenerPorId;
GO

CREATE PROCEDURE dbo.sp_Pedidos_ObtenerPorId
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cabecera
    SELECT
        pe.Id,
        pe.UsuarioId,
        u.NombreUsuario AS Vendedor,
        u.NombreCompleto AS NombreVendedor,
        r.Nombre AS RolVendedor,
        pe.ClienteNombre,
        pe.Total,
        pe.Estatus,
        pe.FechaCreacion
    FROM dbo.Pedido AS pe
    INNER JOIN dbo.Usuario AS u ON pe.UsuarioId = u.Id
    INNER JOIN dbo.Rol AS r ON u.RolId = r.Id
    WHERE pe.Id = @Id;

    -- Detalles
    SELECT
        dp.Id,
        dp.ProductoId,
        p.Clave,
        p.Nombre AS ProductoNombre,
        dp.Cantidad,
        dp.PrecioUnitario,
        dp.Subtotal
    FROM dbo.DetallePedido AS dp
    INNER JOIN dbo.Producto AS p ON dp.ProductoId = p.Id
    WHERE dp.PedidoId = @Id
    ORDER BY dp.Id;
END;
GO

-- ============================================================
-- sp_Pedidos_Crear: transaccion para pedido + detalles + descuento stock
-- @DetallesJSON = '[{"productoId":1,"cantidad":2}, ...]'
-- ============================================================
IF OBJECT_ID('dbo.sp_Pedidos_Crear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Pedidos_Crear;
GO

CREATE PROCEDURE dbo.sp_Pedidos_Crear
    @UsuarioId INT,
    @ClienteNombre NVARCHAR(150),
    @DetallesJSON NVARCHAR(MAX),
    @NuevoPedidoId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Parse detalles desde JSON a tabla temporal
        DECLARE @Detalles TABLE (ProductoId INT, Cantidad INT);

        INSERT INTO @Detalles (ProductoId, Cantidad)
        SELECT productoId, cantidad
        FROM OPENJSON(@DetallesJSON)
        WITH (
            productoId INT '$.productoId',
            cantidad   INT '$.cantidad'
        );

        -- Validar que todos los productos existan + activos + stock suficiente
        IF EXISTS (
            SELECT 1
            FROM @Detalles d
            LEFT JOIN dbo.Producto p ON d.ProductoId = p.Id
            WHERE p.Id IS NULL
               OR p.Activo = 0
               OR p.Existencia < d.Cantidad
        )
        BEGIN
            ;THROW 50001, 'Producto inexistente, inactivo o stock insuficiente', 1;
        END;

        -- Calcular total con precio actual del producto
        DECLARE @Total DECIMAL(18, 2);
        SELECT @Total = ISNULL(SUM(p.PrecioUnitario * d.Cantidad), 0)
        FROM @Detalles d
        INNER JOIN dbo.Producto AS p ON d.ProductoId = p.Id;

        -- Insertar cabecera del pedido
        INSERT INTO dbo.Pedido (UsuarioId, ClienteNombre, Total, Estatus)
        VALUES (@UsuarioId, @ClienteNombre, @Total, 'Pendiente');

        SET @NuevoPedidoId = SCOPE_IDENTITY();

        -- Insertar detalles (snapshot del precio al momento de venta)
        INSERT INTO dbo.DetallePedido (PedidoId, ProductoId, Cantidad, PrecioUnitario)
        SELECT @NuevoPedidoId, d.ProductoId, d.Cantidad, p.PrecioUnitario
        FROM @Detalles d
        INNER JOIN dbo.Producto AS p ON d.ProductoId = p.Id;

        -- Decrementar stock
        UPDATE p
        SET p.Existencia = p.Existencia - d.Cantidad
        FROM dbo.Producto AS p
        INNER JOIN @Detalles d ON p.Id = d.ProductoId;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        ;THROW;
    END CATCH;
END;
GO

PRINT 'Pedidos procedures ready.';
GO