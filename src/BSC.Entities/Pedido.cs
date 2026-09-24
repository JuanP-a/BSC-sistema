namespace BSC.Entities;

public class Pedido
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string? Vendedor { get; set; }
    public string? NombreVendedor { get; set; }
    public string? RolVendedor { get; set; }
    public string ClienteNombre { get; set; } = string.Empty;
    public decimal Total { get; set; }
    public string Estatus { get; set; } = "Pendiente";
    public DateTime FechaCreacion { get; set; }

    public List<DetallePedido> Detalles { get; set; } = new();
}

public class PedidoDetalleInput
{
    public int ProductoId { get; set; }
    public int Cantidad { get; set; }
}
