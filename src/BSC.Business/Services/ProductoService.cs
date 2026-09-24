using BSC.Business.Common;
using BSC.Data.Interfaces;
using BSC.Entities;

namespace BSC.Business.Services;

public class ProductoService
{
    private readonly IProductoRepository _repo;

    public ProductoService(IProductoRepository repo)
    {
        _repo = repo;
    }

    public async Task<IEnumerable<Producto>> ListarAsync(bool soloActivos = true) =>
        await _repo.ListarAsync(soloActivos);

    public async Task<Producto?> ObtenerPorIdAsync(int id) =>
        await _repo.ObtenerPorIdAsync(id);

    public async Task<Result<int>> CrearAsync(Producto producto)
    {
        if (string.IsNullOrWhiteSpace(producto.Clave))
            return Result<int>.Failure("La clave del producto es requerida.", "ProductKeyRequired");

        if (string.IsNullOrWhiteSpace(producto.Nombre))
            return Result<int>.Failure("El nombre del producto es requerido.", "ProductNameRequired");

        if (producto.Existencia < 0)
            return Result<int>.Failure("La existencia no puede ser negativa.", "ProductNegativeStock");

        if (producto.PrecioUnitario < 0)
            return Result<int>.Failure("El precio no puede ser negativo.", "ProductNegativePrice");

        var existente = await _repo.ObtenerPorClaveAsync(producto.Clave);
        if (existente is not null)
            return Result<int>.Failure("Ya existe un producto con esa clave.", "ProductKeyExists");

        var id = await _repo.InsertarAsync(producto.Clave, producto.Nombre, producto.Existencia, producto.PrecioUnitario);
        return Result<int>.Success(id);
    }

    public async Task<IEnumerable<Producto>> ObtenerExistenciasAsync() =>
        await _repo.ObtenerExistenciasAsync();
}
