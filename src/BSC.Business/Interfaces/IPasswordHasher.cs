using BSC.Business.Common;

namespace BSC.Business.Interfaces;

public interface IPasswordHasher
{
    Result ValidarReglas(string plain);

    string Hash(string plain);

    bool Verify(string plain, string hash);
}
