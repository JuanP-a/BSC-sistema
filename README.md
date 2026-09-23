# BSC-sistema

Sistema web para administrar pedidos de la empresa BSC.

## Stack

- **BackEnd:** .NET 8 LTS (C#) — 3 capas (Entities / Data / Business / Api)
- **FrontEnd:** Angular 17+ (scaffolding mínimo: login + dashboard + interceptor JWT)
- **Data:** SQL Server 2022 (Docker local)

## Estructura

```
bsc-sistema/
├── docs/
│   └── diagrams/        # Mermaid: ER, componentes, clases, secuencia
├── db/
│   ├── sql/             # Schema, SPs, views, triggers, seeds
│   └── docker/          # docker-compose SQL Server 2022
├── src/
│   ├── BSC.Entities/    # POCOs / modelos de dominio
│   ├── BSC.Data/        # Repositorios (Dapper + ADO.NET contra SPs)
│   ├── BSC.Business/    # Servicios + validaciones + password rules
│   ├── BSC.Api/         # REST controllers + JWT + Swagger
│   └── BSC.Tests/       # xUnit (unit + integration)
└── frontend/            # Angular 17
```

## Perfiles y permisos

- **Administrador:** CRUD usuarios + asignación rol. Validación contraseñas.
- **Administrativo:** CRUD productos + reportes (existencias, pedidos) + consulta pedidos.
- **Vendedor:** crear pedidos + validación stock en tiempo real.

## Setup local

Ver [`docs/setup.md`](docs/setup.md) (se completa en fase 4).

## Tests

```bash
dotnet test
```

## Licencia

Propietario — BSC © 2026