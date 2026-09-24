using BSC.Entities;

namespace BSC.Data.Interfaces;

public interface IRolRepository
{
    Task<IEnumerable<Rol>> ListarActivosAsync();
}
