using System.Text.Json;
using BSC.Data.Common;
using BSC.Data.Interfaces;
using BSC.Entities;
using Dapper;

namespace BSC.Data.Repositories;

public class PedidoRepository : IPedidoRepository
{
    private readonly IDbConnectionFactory _factory;

    public PedidoRepository(IDbConnectionFactory factory)
    {
        _factory = factory;
    }

    public async Task<IEnumerable<Pedido>> ListarAsync()
    {
        using var connection = _factory.CreateConnection();
        return await connection.QueryAsync<Pedido>(
            "sp_Pedidos_Listar",
            commandType: System.Data.CommandType.StoredProcedure);
    }

    public async Task<Pedido?> ObtenerPorIdAsync(int id)
    {
        using var connection = _factory.CreateConnection();
        using var multi = await connection.QueryMultipleAsync(
            "sp_Pedidos_ObtenerPorId",
            new { Id = id },
            commandType: System.Data.CommandType.StoredProcedure);

        var cabecera = await multi.ReadSingleOrDefaultAsync<Pedido>();
        if (cabecera is null) return null;

        var detalles = (await multi.ReadAsync<DetallePedido>()).ToList();
        cabecera.Detalles = detalles;
        return cabecera;
    }

    public async Task<int> CrearAsync(int usuarioId, string clienteNombre, IEnumerable<PedidoDetalleInput> detalles)
    {
        using var connection = _factory.CreateConnection();
        var parameters = new DynamicParameters();
        parameters.Add("@UsuarioId", usuarioId);
        parameters.Add("@ClienteNombre", clienteNombre);
        parameters.Add("@DetallesJSON", JsonSerializer.Serialize(detalles));
        parameters.Add("@NuevoPedidoId", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);

        await connection.ExecuteAsync(
            "sp_Pedidos_Crear",
            parameters,
            commandType: System.Data.CommandType.StoredProcedure);

        return parameters.Get<int>("@NuevoPedidoId");
    }
}
