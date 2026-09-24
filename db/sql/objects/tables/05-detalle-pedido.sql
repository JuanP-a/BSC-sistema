USE BSC;
GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.DetallePedido', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DetallePedido (
        Id             INT             IDENTITY(1,1) NOT NULL,
        PedidoId       INT             NOT NULL,
        ProductoId     INT             NOT NULL,
        Cantidad       INT             NOT NULL,
        PrecioUnitario DECIMAL(18, 2)  NOT NULL,
        Subtotal       AS (Cantidad * PrecioUnitario) PERSISTED,

        CONSTRAINT PK_DetallePedido PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_DetallePedido_Pedido FOREIGN KEY (PedidoId) REFERENCES dbo.Pedido(Id) ON DELETE CASCADE,
        CONSTRAINT FK_DetallePedido_Producto FOREIGN KEY (ProductoId) REFERENCES dbo.Producto(Id),
        CONSTRAINT CK_DetallePedido_Cantidad_Pos CHECK (Cantidad > 0),
        CONSTRAINT CK_DetallePedido_PrecioUnitario_NonNeg CHECK (PrecioUnitario >= 0)
    );
END;
GO

PRINT 'DetallePedido table ready.';
GO