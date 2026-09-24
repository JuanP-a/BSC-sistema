using BSC.Entities;

namespace BSC.Data.Interfaces;

public interface IUsuarioRepository
{
    Task<Usuario?> ObtenerPorNombreAsync(string nombreUsuario);

    Task<Usuario?> ObtenerPorIdAsync(int id);

    Task<IEnumerable<Usuario>> ListarAsync();

    Task<int> InsertarAsync(string nombreUsuario, string contrasenaHash, string nombreCompleto, string? correo, int rolId);

    Task ActualizarAsync(int id, string nombreCompleto, string? correo, int rolId, bool activo, string? contrasenaHash);
}
