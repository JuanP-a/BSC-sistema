using BSC.Data.Common;
using BSC.Data.Interfaces;
using BSC.Entities;
using Dapper;

namespace BSC.Data.Repositories;

public class RolRepository : IRolRepository
{
    private readonly IDbConnectionFactory _factory;

    public RolRepository(IDbConnectionFactory factory)
    {
        _factory = factory;
    }

    public async Task<IEnumerable<Rol>> ListarActivosAsync()
    {
        using var connection = _factory.CreateConnection();
        return await connection.QueryAsync<Rol>(
            "sp_Roles_Listar",
            commandType: System.Data.CommandType.StoredProcedure);
    }
}
