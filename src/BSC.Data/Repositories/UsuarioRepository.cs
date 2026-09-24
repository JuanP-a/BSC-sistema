using BSC.Data.Common;
using BSC.Data.Interfaces;
using BSC.Entities;
using Dapper;

namespace BSC.Data.Repositories;

public class UsuarioRepository : IUsuarioRepository
{
    private readonly IDbConnectionFactory _factory;

    public UsuarioRepository(IDbConnectionFactory factory)
    {
        _factory = factory;
    }

    public async Task<Usuario?> ObtenerPorNombreAsync(string nombreUsuario)
    {
        using var connection = _factory.CreateConnection();
        return await connection.QuerySingleOrDefaultAsync<Usuario>(
            "sp_Usuarios_ObtenerPorNombre",
            new { NombreUsuario = nombreUsuario },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    public async Task<Usuario?> ObtenerPorIdAsync(int id)
    {
        using var connection = _factory.CreateConnection();
        return await connection.QuerySingleOrDefaultAsync<Usuario>(
            "sp_Usuarios_ObtenerPorId",
            new { Id = id },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Usuario>> ListarAsync()
    {
        using var connection = _factory.CreateConnection();
        return await connection.QueryAsync<Usuario>(
            "sp_Usuarios_Listar",
            commandType: System.Data.CommandType.StoredProcedure);
    }

    public async Task<int> InsertarAsync(string nombreUsuario, string contrasenaHash, string nombreCompleto, string? correo, int rolId)
    {
        using var connection = _factory.CreateConnection();
        var parameters = new DynamicParameters();
        parameters.Add("@NombreUsuario", nombreUsuario);
        parameters.Add("@ContrasenaHash", contrasenaHash);
        parameters.Add("@NombreCompleto", nombreCompleto);
        parameters.Add("@Correo", correo);
        parameters.Add("@RolId", rolId);
        parameters.Add("@NuevoId", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);

        await connection.ExecuteAsync(
            "sp_Usuarios_Insertar",
            parameters,
            commandType: System.Data.CommandType.StoredProcedure);

        return parameters.Get<int>("@NuevoId");
    }

    public async Task ActualizarAsync(int id, string nombreCompleto, string? correo, int rolId, bool activo, string? contrasenaHash)
    {
        using var connection = _factory.CreateConnection();
        await connection.ExecuteAsync(
            "sp_Usuarios_Actualizar",
            new
            {
                Id = id,
                NombreCompleto = nombreCompleto,
                Correo = correo,
                RolId = rolId,
                Activo = activo,
                ContrasenaHash = contrasenaHash
            },
            commandType: System.Data.CommandType.StoredProcedure);
    }
}
