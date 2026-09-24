using BSC.Business.Common;
using BSC.Data.Interfaces;
using BSC.Entities;

namespace BSC.Business.Services;

public class PedidoService
{
    private readonly IPedidoRepository _pedidoRepo;
    private readonly IProductoRepository _productoRepo;

    public PedidoService(IPedidoRepository pedidoRepo, IProductoRepository productoRepo)
    {
        _pedidoRepo = pedidoRepo;
        _productoRepo = productoRepo;
    }

    public async Task<IEnumerable<Pedido>> ListarAsync() =>
        await _pedidoRepo.ListarAsync();

    public async Task<Pedido?> ObtenerPorIdAsync(int id) =>
        await _pedidoRepo.ObtenerPorIdAsync(id);

    public async Task<Result<int>> CrearAsync(int vendedorId, string clienteNombre, IEnumerable<PedidoDetalleInput> detalles)
    {
        if (string.IsNullOrWhiteSpace(clienteNombre))
            return Result<int>.Failure("El nombre del cliente es requerido.", "ClientNameRequired");

        var detallesList = detalles?.ToList() ?? new List<PedidoDetalleInput>();
        if (detallesList.Count == 0)
            return Result<int>.Failure("El pedido debe tener al menos un detalle.", "PedidoNoDetalles");

        if (detallesList.Any(d => d.Cantidad <= 0))
            return Result<int>.Failure("Las cantidades deben ser mayores a cero.", "PedidoInvalidCantidad");

        // Defense-in-depth: Business tambien valida stock antes de delegar al SP.
        foreach (var detalle in detallesList)
        {
            var producto = await _productoRepo.ObtenerPorIdAsync(detalle.ProductoId);
            if (producto is null || !producto.Activo)
                return Result<int>.Failure($"Producto {detalle.ProductoId} no disponible.", "ProductNotFound");

            if (producto.Existencia < detalle.Cantidad)
                return Result<int>.Failure($"Stock insuficiente para {producto.Nombre}.", "StockInsuficiente");
        }

        try
        {
            var id = await _pedidoRepo.CrearAsync(vendedorId, clienteNombre, detallesList);
            return Result<int>.Success(id);
        }
        catch (Exception ex)
        {
            return Result<int>.Failure(ex.Message, "PedidoCreateError");
        }
    }
}
