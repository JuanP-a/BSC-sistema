USE BSC;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- vw_Productos_Existencias: catalogo activo con clasificacion de stock
-- Reutilizada por el reporte de existencias del perfil Administrativo.
-- ============================================================
IF OBJECT_ID('dbo.vw_Productos_Existencias', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Productos_Existencias;
GO

CREATE VIEW dbo.vw_Productos_Existencias
AS
SELECT
    p.Id,
    p.Clave,
    p.Nombre,
    p.Existencia,
    p.PrecioUnitario,
    p.Activo,
    CASE
        WHEN p.Existencia = 0 THEN 'Agotado'
        WHEN p.Existencia < 10 THEN 'Bajo'
        ELSE 'Disponible'
    END AS EstatusStock
FROM dbo.Producto AS p
WHERE p.Activo = 1;
GO

-- ============================================================
-- vw_Pedidos_Completo: pedidos con vendedor + metricas agregadas
-- Reutilizada por el reporte de pedidos del perfil Administrativo.
-- ============================================================
IF OBJECT_ID('dbo.vw_Pedidos_Completo', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Pedidos_Completo;
GO

CREATE VIEW dbo.vw_Pedidos_Completo
AS
SELECT
    pe.Id,
    pe.ClienteNombre,
    pe.Total,
    pe.Estatus,
    pe.FechaCreacion,
    u.NombreUsuario AS Vendedor,
    r.Nombre AS RolVendedor,
    COUNT(dp.Id) AS NumeroDetalles,
    ISNULL(SUM(dp.Cantidad), 0) AS TotalPiezas
FROM dbo.Pedido AS pe
INNER JOIN dbo.Usuario AS u ON pe.UsuarioId = u.Id
INNER JOIN dbo.Rol AS r ON u.RolId = r.Id
LEFT JOIN dbo.DetallePedido AS dp ON pe.Id = dp.PedidoId
GROUP BY
    pe.Id, pe.ClienteNombre, pe.Total, pe.Estatus, pe.FechaCreacion,
    u.NombreUsuario, r.Nombre;
GO

-- ============================================================
-- vw_Productos_MasVendidos: productos con totales historicos
-- Reutilizada por el reporte de productos mas vendidos.
-- ============================================================
IF OBJECT_ID('dbo.vw_Productos_MasVendidos', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Productos_MasVendidos;
GO

CREATE VIEW dbo.vw_Productos_MasVendidos
AS
SELECT
    p.Id,
    p.Clave,
    p.Nombre,
    ISNULL(SUM(dp.Cantidad), 0) AS TotalVendido,
    ISNULL(SUM(dp.Subtotal), 0) AS IngresoTotal,
    COUNT(DISTINCT dp.PedidoId) AS NumeroPedidos
FROM dbo.Producto AS p
LEFT JOIN dbo.DetallePedido AS dp ON p.Id = dp.ProductoId
GROUP BY p.Id, p.Clave, p.Nombre;
GO

PRINT 'Views ready.';
GO