USE BSC;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- tr_DetallePedido_ValidarStock
-- Defensa en profundidad: el SP ya valida stock antes de insertar,
-- pero el trigger revisa despues del descuento que la Existencia
-- no haya quedado negativa (catches bugs + accesos directos a tabla).
-- ============================================================
IF OBJECT_ID('dbo.tr_DetallePedido_ValidarStock', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DetallePedido_ValidarStock;
GO

CREATE TRIGGER dbo.tr_DetallePedido_ValidarStock
ON dbo.DetallePedido
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        INNER JOIN dbo.Producto AS p ON i.ProductoId = p.Id
        WHERE p.Existencia < 0
    )
    BEGIN
        ROLLBACK;
        ;THROW 50010, 'Stock negativo detectado por trigger', 1;
    END;
END;
GO

-- ============================================================
-- tr_DetallePedido_RestaurarStock
-- Al borrar un DetallePedido (ej. cancelacion), restaura la Existencia
-- del Producto correspondiente. ON DELETE CASCADE del FK dispara este
-- trigger cuando se borra el Pedido padre completo.
-- ============================================================
IF OBJECT_ID('dbo.tr_DetallePedido_RestaurarStock', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DetallePedido_RestaurarStock;
GO

CREATE TRIGGER dbo.tr_DetallePedido_RestaurarStock
ON dbo.DetallePedido
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.Existencia = p.Existencia + d.Cantidad
    FROM dbo.Producto AS p
    INNER JOIN deleted AS d ON p.Id = d.ProductoId;
END;
GO

PRINT 'Triggers ready.';
GO