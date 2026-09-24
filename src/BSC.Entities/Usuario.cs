namespace BSC.Entities;

public class Usuario
{
    public int Id { get; set; }
    public string NombreUsuario { get; set; } = string.Empty;
    public string ContrasenaHash { get; set; } = string.Empty;
    public string NombreCompleto { get; set; } = string.Empty;
    public string? Correo { get; set; }
    public int RolId { get; set; }
    public string? RolNombre { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
}
