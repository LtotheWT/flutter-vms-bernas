# Agent Instructions (vms_bernas)

## Architecture (DDD)
- Use a layered, domain-first structure. The `domain` layer is pure Dart and has no Flutter imports.
- Keep domain logic independent from infrastructure and UI.
- Prefer immutable models and explicit value objects.

## Folder structure
- `lib/domain/`
  - `entities/`
  - `value_objects/`
  - `repositories/` (abstract interfaces)
  - `usecases/` (application services)
- `lib/data/`
  - `models/` (DTOs)
  - `datasources/` (API, local storage)
  - `repositories/` (implementations)
- `lib/presentation/`
  - `app/` (router, app shell)
  - `pages/`
  - `widgets/`
  - `state/` (Riverpod providers + state classes)
  - Prefer extracting shared UI into `widgets/` and reusing from there.

## Dependencies
- UI depends on `domain` via `usecases`.
- `data` depends on `domain` and provides `repositories`.
- `domain` must not depend on `data` or `presentation`.

## State management (Riverpod)
- Providers live in `lib/presentation/state/`.
- Expose usecases as providers, and repositories as `Provider`/`FutureProvider` from `data`.
- Keep provider scopes in `main.dart` and avoid global singletons.

## Routing (GoRouter)
- Router config in `lib/presentation/app/router.dart`.
- Keep route names/paths centralized and typed helpers where possible.

## Naming
- Use suffixes: `*Repository`, `*UseCase`, `*Entity`, `*Dto`.
- Use `snake_case` for file names.
- Keep feature folders if a domain grows large, but preserve layer separation.

## Testing
- Domain layer: pure unit tests.
- Data layer: repository + datasource tests.
- Presentation: widget tests for critical flows.
