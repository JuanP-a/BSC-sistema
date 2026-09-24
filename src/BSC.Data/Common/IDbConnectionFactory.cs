using System.Data;

namespace BSC.Data.Common;

public interface IDbConnectionFactory
{
    IDbConnection CreateConnection();
}
