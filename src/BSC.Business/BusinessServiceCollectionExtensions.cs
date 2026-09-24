using BSC.Business.Interfaces;
using BSC.Business.Security;
using BSC.Business.Services;
using BSC.Data.Common;
using BSC.Data.Interfaces;
using BSC.Data.Repositories;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace BSC.Business;

public static class BusinessServiceCollectionExtensions
{
    public static IServiceCollection AddBscBusinessServices(this IServiceCollection services, IConfiguration configuration)
    {
        // Conexion DB (env var BSC_DB_CONNECTION o ConnectionStrings:BSC)
        var connectionString = configuration["BSC_DB_CONNECTION"]
            ?? configuration.GetConnectionString("BSC")
            ?? throw new InvalidOperationException(
                "Connection string not configured. Set BSC_DB_CONNECTION env var or ConnectionStrings:BSC in config.");

        services.AddSingleton<IDbConnectionFactory>(_ => new SqlConnectionFactory(connectionString));

        // Repositorios (Scoped: uno por request HTTP)
        services.AddScoped<IRolRepository, RolRepository>();
        services.AddScoped<IUsuarioRepository, UsuarioRepository>();
        services.AddScoped<IProductoRepository, ProductoRepository>();
        services.AddScoped<IPedidoRepository, PedidoRepository>();

        // Security (Singleton: stateless)
        services.AddSingleton<IPasswordHasher, PasswordHasher>();
        services.AddSingleton<ITokenGenerator, JwtTokenGenerator>();

        // Servicios de dominio (Scoped)
        services.AddScoped<AuthService>();
        services.AddScoped<ProductoService>();
        services.AddScoped<PedidoService>();

        return services;
    }
}
