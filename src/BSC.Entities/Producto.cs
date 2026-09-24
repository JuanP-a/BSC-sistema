namespace BSC.Entities;

public class Producto
{
    public int Id { get; set; }
    public string Clave { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public int Existencia { get; set; }
    public decimal PrecioUnitario { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
}
