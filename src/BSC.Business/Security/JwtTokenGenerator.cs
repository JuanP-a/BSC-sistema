using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BSC.Business.Interfaces;
using BSC.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace BSC.Business.Security;

public class JwtTokenGenerator : ITokenGenerator
{
    private readonly string _issuer;
    private readonly string _audience;
    private readonly string _secret;
    private readonly int _expirationMinutes;

    public JwtTokenGenerator(IConfiguration configuration)
    {
        _issuer = configuration["Jwt:Issuer"] ?? "BSC";
        _audience = configuration["Jwt:Audience"] ?? "BSC";
        _secret = configuration["Jwt:Secret"]
            ?? throw new InvalidOperationException("JWT secret not configured.");
        _expirationMinutes = int.Parse(configuration["Jwt:ExpirationMinutes"] ?? "60");
    }

    public string Generar(Usuario usuario)
    {
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, usuario.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.UniqueName, usuario.NombreUsuario),
            new Claim(ClaimTypes.Role, usuario.RolNombre ?? string.Empty),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secret));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _issuer,
            audience: _audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_expirationMinutes),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
