using BSC.Entities;

namespace BSC.Data.Interfaces;

public interface IPedidoRepository
{
    Task<IEnumerable<Pedido>> ListarAsync();

    Task<Pedido?> ObtenerPorIdAsync(int id);

    Task<int> CrearAsync(int usuarioId, string clienteNombre, IEnumerable<PedidoDetalleInput> detalles);
}
