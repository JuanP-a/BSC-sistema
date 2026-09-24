using BSC.Data.Common;
using BSC.Data.Interfaces;
using BSC.Entities;
using Dapper;

namespace BSC.Data.Repositories;

public class ProductoRepository : IProductoRepository
{
    private readonly IDbConnectionFactory _factory;

    public ProductoRepository(IDbConnectionFactory factory)
    {
        _factory = factory;
    }

    public async Task<IEnumerable<Producto>> ListarAsync(bool soloActivos = true)
    {
        using var connection = _factory.CreateConnection();
        return await connection.QueryAsync<Producto>(
            "sp_Productos_Listar",
            new { SoloActivos = soloActivos },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    public async Task<Producto?> ObtenerPorIdAsync(int id)
    {
        using var connection = _factory.CreateConnection();
        return await connection.QuerySingleOrDefaultAsync<Producto>(
            "sp_Productos_ObtenerPorId",
            new { Id = id },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    public async Task<Producto?> ObtenerPorClaveAsync(string clave)
    {
        using var connection = _factory.CreateConnection();
        return await connection.QuerySingleOrDefaultAsync<Producto>(
            "sp_Productos_ObtenerPorClave",
            new { Clave = clave },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    public async Task<int> InsertarAsync(string clave, string nombre, int existencia, decimal precioUnitario)
    {
        using var connection = _factory.CreateConnection();
        var parameters = new DynamicParameters();
        parameters.Add("@Clave", clave);
        parameters.Add("@Nombre", nombre);
        parameters.Add("@Existencia", existencia);
        parameters.Add("@PrecioUnitario", precioUnitario);
        parameters.Add("@NuevoId", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);

        await connection.ExecuteAsync(
            "sp_Productos_Insertar",
            parameters,
            commandType: System.Data.CommandType.StoredProcedure);

        return parameters.Get<int>("@NuevoId");
    }

    public async Task ActualizarAsync(int id, string clave, string nombre, int existencia, decimal precioUnitario, bool activo)
    {
        using var connection = _factory.CreateConnection();
        await connection.ExecuteAsync(
            "sp_Productos_Actualizar",
            new
            {
                Id = id,
                Clave = clave,
                Nombre = nombre,
                Existencia = existencia,
                PrecioUnitario = precioUnitario,
                Activo = activo
            },
            commandType: System.Data.CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Producto>> ObtenerExistenciasAsync()
    {
        using var connection = _factory.CreateConnection();
        return await connection.QueryAsync<Producto>(
            "sp_Productos_ObtenerExistencias",
            commandType: System.Data.CommandType.StoredProcedure);
    }
}
