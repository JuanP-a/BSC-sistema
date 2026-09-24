using BSC.Entities;

namespace BSC.Data.Interfaces;

public interface IProductoRepository
{
    Task<IEnumerable<Producto>> ListarAsync(bool soloActivos = true);

    Task<Producto?> ObtenerPorIdAsync(int id);

    Task<Producto?> ObtenerPorClaveAsync(string clave);

    Task<int> InsertarAsync(string clave, string nombre, int existencia, decimal precioUnitario);

    Task ActualizarAsync(int id, string clave, string nombre, int existencia, decimal precioUnitario, bool activo);

    Task<IEnumerable<Producto>> ObtenerExistenciasAsync();
}
