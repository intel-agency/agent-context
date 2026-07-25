# App stacks

nam20485

The `.agents/rules/app-stacks/` directory contains three pre-defined tech stack profiles. Each file is named by a slug ID and declares the platform, language, package manager, backend, frontend, database, testing tools, linting tools, and CI setup for that stack. App development and implementation plans reference these by slug ID to specify the technology choices for a project, so the stack is declared once and resolved consistently across every agent and script that touches the project.

## How slug IDs work

A slug ID is the filename of a stack profile (without the `.md` extension). When an app development plan or implementation plan needs to specify a tech stack, it names the slug ID, and agents read the corresponding file under `.agents/rules/app-stacks/` to get the full stack definition. This keeps the plan document short while the detailed tool and package list lives in one place.

The directory is self-describing: there is no separate `app-stacks.md` rules file indexing the stacks. `AGENTS.md` lists the available slug IDs inline in its App Stacks section, and each file in the directory is a complete stack definition.

## The three stacks

| Slug ID | Platform | Language | Package manager |
| --- | --- | --- | --- |
| `dotnet-aspire-aspnet-blazor` | web | .NET C# | nuget |
| `dotnet-avalonia-xplatform-desktop` | desktop | .NET C# | nuget |
| `python-uv-fastapi-vite` | web | Python | uv |

### dotnet-aspire-aspnet-blazor

A web stack built on the .NET Aspire Starter App template. It targets Windows, Linux, and macOS.

- **Backend**: ASP.NET Core, .NET Aspire
- **Frontend**: Blazor WebAssembly
- **Database**: PostgreSQL with Entity Framework Core
- **Packages**: .NET Community Toolkit, Windows Community Toolkit, .NET Aspire Community Toolkit, Entity Framework Core
- **Containerization**: Docker, Docker Compose
- **Testing**: xUnit, coverlet, reportgenerator
- **Linting**: dotnet format
- **CI**: GitHub Actions workflows

File: `.agents/rules/app-stacks/dotnet-aspire-aspnet-blazor.md`

### dotnet-avalonia-xplatform-desktop

A cross-platform desktop stack built on the Avalonia Desktop App template. It targets Windows, Linux, and macOS.

- **Backend**: Avalonia, .NET Core
- **Database**: SQLite (optional, as needed)
- **Packages**: .NET Community Toolkit, Windows Community Toolkit, Entity Framework Core
- **Containerization**: Docker, Docker Compose
- **Testing**: xUnit, coverlet, reportgenerator
- **Linting**: dotnet format
- **CI**: GitHub Actions workflows

File: `.agents/rules/app-stacks/dotnet-avalonia-xplatform-desktop.md`

### python-uv-fastapi-vite

A web stack combining a Python FastAPI backend with a Vite frontend. It targets Windows, Linux, and macOS.

- **Backend**: FastAPI, Uvicorn
- **Frontend**: Vite with React, Vue, or Svelte
- **Database**: PostgreSQL with SQLAlchemy
- **Packages**: llmlite (inference engine)
- **Containerization**: Docker, Docker Compose
- **Testing**: Pytest
- **Linting**: ruff
- **Type checking**: basedpyright
- **CI**: GitHub Actions workflows

File: `.agents/rules/app-stacks/python-uv-fastapi-vite.md`

## Common patterns across stacks

All three stacks target all three desktop operating systems (Windows, Linux, macOS) and use Docker with Docker Compose for containerization. All three run their CI on GitHub Actions. The two .NET stacks share the same testing toolchain (xUnit, coverlet, reportgenerator) and the same linter (dotnet format). The Python stack uses its own ecosystem equivalents (Pytest for testing, ruff for linting, basedpyright for type checking).

## Key source files

| Path | What it contains |
| --- | --- |
| `.agents/rules/app-stacks/dotnet-aspire-aspnet-blazor.md` | .NET Aspire web stack profile |
| `.agents/rules/app-stacks/dotnet-avalonia-xplatform-desktop.md` | .NET Avalonia desktop stack profile |
| `.agents/rules/app-stacks/python-uv-fastapi-vite.md` | Python FastAPI web stack profile |
| `AGENTS.md` | Lists available slug IDs in the App Stacks section |

## Related pages

- [Systems](index.md)
- [Memory and rules system](memory-and-rules.md)
- [Architecture](../overview/architecture.md)
- [Getting started](../overview/getting-started.md)
- [Dependencies](../reference/dependencies.md)
