# BSC-sistema

Sistema web para administrar pedidos de la empresa BSC.

Permite gestionar usuarios por perfil (Administrador, Administrativo, Vendedor),
productos, pedidos con validacion de stock en tiempo real, y reportes de existencias
y pedidos.

## Stack

- **BackEnd:** .NET 8 LTS (C#) — arquitectura 3 capas (Entities / Data / Business / Api)
- **FrontEnd:** Angular 17+ (cliente minimo fuera del alcance de esta entrega)
- **Data:** SQL Server 2022 en Docker
- **Auth:** JWT (HS256) + BCrypt (reglas: 8+ chars, letras + numeros)
- **Acceso a datos:** Dapper ejecutando Stored Procedures (sin EF Core)
- **Documentacion:** Mermaid (diagramas ER y de componentes)

## Prerequisitos

- macOS / Linux / Windows
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (o Docker Engine + Compose v2)
- Cliente SQL Server: `sqlcmd` o Azure Data Studio (para aplicar el schema inicial)

## Quick start

### 1. Levantar SQL Server

```bash
cd db/docker
cp .env.example .env

# Editar db/docker/.env si queres cambiar SA_PASSWORD (default: YourStrong!Passw0rd)

docker compose up -d

# Esperar ~30s a que SQL Server inicialice
docker compose ps
```

### 2. Aplicar objetos SQL

Ejecutar los scripts `.sql` en orden. Conexion: `localhost,1433` con `sa` + password
definida en `.env`.

Orden de aplicacion (carpeta `db/sql/objects/`):

1. `tables/` — archivos `00` a `05` (database, rol, usuario, producto, pedido, detalle-pedido)
2. `indexes/01-indexes-fk-reportes.sql`
3. `views/01-reportes.sql`
4. `procedures/auth/sp-usuarios-autenticar.sql`
5. `procedures/usuarios/sp-usuarios-crud.sql`
6. `procedures/productos/sp-productos-crud.sql`
7. `procedures/pedidos/sp-pedidos-crud.sql`
8. `triggers/01-triggers-detalle-pedido.sql`

Ejemplo via `docker exec` + `sqlcmd` (repetir cambiando el path del script):

```bash
docker exec -i bsc-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong!Passw0rd' -C \
  < db/sql/objects/tables/00-create-database.sql
```

### 3. Sembrar roles base (1 sola vez)

```sql
INSERT INTO dbo.Rol (Nombre, Descripcion) VALUES
  ('Administrador',  'Control total del sistema'),
  ('Administrativo', 'Gestion de productos y reportes'),
  ('Vendedor',       'Colocacion de pedidos con validacion de stock');
```

Para crear el primer usuario administrador se necesita un hash BCrypt. La forma
mas simple: registrar uno via API una vez que exista el rol `Administrador` (ver
seccion "Crear primer admin" mas abajo) o usar el helper:

```bash
# Genera hash BCrypt de una contrasena (requiere .NET 8 + dotnet-script o proyecto)
dotnet run --project scripts/HashGen -- "Admin1234"
```

### 4. Configurar variables de entorno

La API lee configuracion desde env vars (con fallback a `appsettings.json`).

```bash
export BSC_DB_CONNECTION='Server=localhost,1433;Database=BSC;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True;'
export Jwt__Secret='un-secret-de-al-menos-32-caracteres-xxxxxxxxxxxxxx'
```

### 5. Correr API

```bash
cd src/BSC.Api
dotnet run
```

Abrir Swagger UI en `http://localhost:5000/swagger` (puerto puede variar — ver consola).

### 6. Probar login

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"nombreUsuario":"admin","contrasena":"Admin1234"}'
```

Respuesta esperada:

```json
{
  "token": "eyJhbGciOi...",
  "rol": "Administrador",
  "usuarioId": 1,
  "nombreUsuario": "admin",
  "nombreCompleto": "Administrador General"
}
```

Usar el token en requests subsiguientes: `Authorization: Bearer <token>`.

## Endpoints REST

| Metodo | Ruta | Rol requerido | Descripcion |
|--------|------|---------------|-------------|
| POST | `/api/auth/login` | publico | Login, devuelve JWT |
| GET  | `/api/productos` | Admin/Administrativo | Listar catalogo |
| GET  | `/api/productos/{id}` | Admin/Administrativo | Obtener producto |
| POST | `/api/productos` | Admin/Administrativo | Crear producto |
| GET  | `/api/productos/existencias` | Admin/Administrativo | Reporte de existencias |
| GET  | `/api/pedidos` | Admin/Administrativo | Listar pedidos |
| GET  | `/api/pedidos/{id}` | autenticado | Detalle completo del pedido |
| POST | `/api/pedidos` | Vendedor | Crear pedido (valida stock) |

Todas las requests autenticadas requieren header `Authorization: Bearer <token>`.

## Tests

```bash
dotnet test
```

Estructura del proyecto de tests presente (`src/BSC.Tests/`); tests unitarios
criticos pueden agregarse como punto de extension.

## Estructura del proyecto

```
bsc-sistema/
|-- docs/diagrams/        Mermaid (ER + componentes)
|-- db/
|   |-- sql/              Schema, SPs, views, triggers
|   `-- docker/           docker-compose SQL Server 2022
|-- src/
|   |-- BSC.Entities/     POCOs de dominio (5 entidades)
|   |-- BSC.Data/         Repos Dapper contra SPs
|   |-- BSC.Business/     Servicios + BCrypt + JWT
|   |-- BSC.Api/          Controllers + DI + Swagger
|   `-- BSC.Tests/        xUnit (estructura)
`-- README.md
```

## Arquitectura

```
Cliente (Angular)  --HTTP+JSON-->  BSC.Api  -->  BSC.Business  -->  BSC.Data  -->  SQL Server
                                       JWT          servicios       Dapper          SPs + Views + Triggers
```

- **BSC.Entities** — POCOs sin dependencias. Rol, Usuario, Producto, Pedido, DetallePedido.
- **BSC.Data** — ejecucion SQL contra Stored Procedures (sin logica de negocio).
- **BSC.Business** — validaciones, orquestacion, password rules (BCrypt), stock check defensivo.
- **BSC.Api** — traduccion HTTP, JWT, autorizacion por rol (`[Authorize(Roles="...")]`), Swagger.

### Password rules (BCrypt)

Aplicadas en `BSC.Business.Security.PasswordHasher.ValidarReglas`:

- Minimo 8 caracteres
- Al menos una letra
- Al menos un digito
- Hash con `BCrypt.Net-Next` (work factor 11)

## Licencia

Propietario — BSC © 2026
