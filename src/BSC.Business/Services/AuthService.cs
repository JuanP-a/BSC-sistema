using BSC.Business.Common;
using BSC.Business.Interfaces;
using BSC.Data.Interfaces;
using BSC.Entities;

namespace BSC.Business.Services;

public class AuthService
{
    private readonly IUsuarioRepository _usuarioRepo;
    private readonly IPasswordHasher _hasher;
    private readonly ITokenGenerator _token;

    public AuthService(IUsuarioRepository usuarioRepo, IPasswordHasher hasher, ITokenGenerator token)
    {
        _usuarioRepo = usuarioRepo;
        _hasher = hasher;
        _token = token;
    }

    public async Task<Result<AuthResponse>> LoginAsync(LoginRequest request)
    {
        var val = _hasher.ValidarReglas(request.Contrasena);
        if (!val.IsSuccess)
            return Result<AuthResponse>.Failure(val.Error!, val.ErrorCode);

        var usuario = await _usuarioRepo.ObtenerPorNombreAsync(request.NombreUsuario);
        if (usuario is null || !usuario.Activo)
            return Result<AuthResponse>.Failure("Credenciales invalidas.", "InvalidCredentials");

        if (!_hasher.Verify(request.Contrasena, usuario.ContrasenaHash))
            return Result<AuthResponse>.Failure("Credenciales invalidas.", "InvalidCredentials");

        var jwt = _token.Generar(usuario);
        return Result<AuthResponse>.Success(new AuthResponse(jwt, usuario));
    }
}

public class LoginRequest
{
    public string NombreUsuario { get; set; } = string.Empty;
    public string Contrasena { get; set; } = string.Empty;
}

public class AuthResponse
{
    public string Token { get; }
    public string Rol { get; }
    public int UsuarioId { get; }
    public string NombreUsuario { get; }
    public string NombreCompleto { get; }

    public AuthResponse(string token, Usuario usuario)
    {
        Token = token;
        Rol = usuario.RolNombre ?? string.Empty;
        UsuarioId = usuario.Id;
        NombreUsuario = usuario.NombreUsuario;
        NombreCompleto = usuario.NombreCompleto;
    }
}
