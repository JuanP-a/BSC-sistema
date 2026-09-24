using BSC.Entities;

namespace BSC.Business.Interfaces;

public interface ITokenGenerator
{
    string Generar(Usuario usuario);
}
