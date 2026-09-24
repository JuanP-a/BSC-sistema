USE BSC;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- Nonclustered indexes for FK lookups + common report queries.
-- Clustered PKs are auto-created by PRIMARY KEY constraints (not redefined here).

-- FK on Usuario.RolId (for "usuarios por rol" lookups)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Usuario_RolId' AND object_id = OBJECT_ID('dbo.Usuario'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Usuario_RolId ON dbo.Usuario (RolId);
END;
GO

-- FK on Pedido.UsuarioId (for "pedidos por vendedor" reports)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pedido_UsuarioId' AND object_id = OBJECT_ID('dbo.Pedido'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pedido_UsuarioId ON dbo.Pedido (UsuarioId);
END;
GO

-- Date index on Pedido.FechaCreacion DESC (for "pedidos recientes" reports)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pedido_FechaCreacion' AND object_id = OBJECT_ID('dbo.Pedido'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pedido_FechaCreacion ON dbo.Pedido (FechaCreacion DESC);
END;
GO

-- FK on DetallePedido.PedidoId (for "detalles de un pedido")
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DetallePedido_PedidoId' AND object_id = OBJECT_ID('dbo.DetallePedido'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DetallePedido_PedidoId ON dbo.DetallePedido (PedidoId);
END;
GO

-- FK on DetallePedido.ProductoId (for "productos mas vendidos" reports)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DetallePedido_ProductoId' AND object_id = OBJECT_ID('dbo.DetallePedido'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DetallePedido_ProductoId ON dbo.DetallePedido (ProductoId);
END;
GO

-- Filtered index on Producto.Activo (fast lookup of active catalog)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Producto_Activo' AND object_id = OBJECT_ID('dbo.Producto'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Producto_Activo ON dbo.Producto (Activo) WHERE Activo = 1;
END;
GO

PRINT 'Indexes ready.';
GO