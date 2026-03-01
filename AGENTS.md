# Agent Instructions (vms_bernas)

## Architecture (DDD)
- Use a layered, domain-first structure. The `domain` layer is pure Dart and has no Flutter imports.
- Keep domain logic independent from infrastructure and UI.
- Prefer immutable models and explicit value objects.
- For idempotent submissions, manage idempotency key lifecycle in presentation state (stable per logical request, reset on payload change).

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
  - Use shared field/sheet widgets from `lib/presentation/widgets/labeled_form_rows.dart` and `lib/presentation/widgets/searchable_option_sheet.dart` when implementing select/text rows and searchable option sheets.

## Dependencies
- UI depends on `domain` via `usecases`.
- `data` depends on `domain` and provides `repositories`.
- `domain` must not depend on `data` or `presentation`.

## State management (Riverpod)
- Providers live in `lib/presentation/state/`.
- Expose usecases as providers, and repositories as `Provider`/`FutureProvider` from `data`.
- Keep provider scopes in `main.dart` and avoid global singletons.
- Place cross-screen reference option providers in `lib/presentation/state/reference_providers.dart`.
- Keep feature-specific providers (e.g., invitation form submission state) in feature files like `lib/presentation/state/invitation_add_providers.dart`.
- Prefer reusing shared providers rather than duplicating provider trees per page.

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

## Workflow orchestration
1. Plan node default
   - Enter plan mode for any non-trivial task (3+ steps or architectural decisions).
   - If something goes sideways, stop and re-plan immediately; do not keep pushing.
   - Use plan mode for verification steps, not just building.
   - Write detailed specs upfront to reduce ambiguity.
2. Subagent strategy
   - Use subagents liberally to keep the main context window clean.
   - Offload research, exploration, and parallel analysis to subagents.
   - For complex problems, throw more compute at it via subagents.
   - One task per subagent for focused execution.
3. Self-improvement loop
   - After any correction from the user, update `tasks/lessons.md`.
   - Write rules for yourself that prevent the same mistake.
   - Ruthlessly iterate on these lessons until mistake rate drops.
   - Review lessons at session start for the relevant project.
4. Verification before done
   - Never mark a task complete without proving it works.
   - Diff behavior between main and your changes when relevant.
   - Ask yourself: "Would a staff engineer approve this?"
   - Run tests, check logs, and demonstrate correctness.
5. Demand elegance (balanced)
   - For non-trivial changes, pause and ask: "Is there a more elegant way?"
   - If a fix feels hacky, ask: "Knowing everything I know now, implement the elegant solution."
   - Skip this for simple, obvious fixes; do not over-engineer.
   - Challenge your own work before presenting it.
6. Autonomous bug fixing
   - When given a bug report, fix it without requiring hand-holding.
   - Point at logs, errors, and failing tests, then resolve them.
   - Require zero context switching from the user.
   - Fix failing CI tests without being told how.

## Task management
1. Plan first: write a plan to `tasks/todo.md` with checkable items.
2. Verify plan: check in before starting implementation.
3. Track progress: mark items complete as you go.
4. Explain changes: provide a high-level summary at each step.
5. Document results: add a review section to `tasks/todo.md`.
6. Capture lessons: update `tasks/lessons.md` after corrections.

## Core principles
- Simplicity first: make every change as simple as possible and impact minimal code.
- No laziness: find root causes and avoid temporary fixes; maintain senior developer standards.
- Minimal impact: touch only what is necessary and avoid introducing bugs.
- Reuse first: when the same formatting/parsing/helper logic appears in 2+ files, extract a shared utility in `lib/core/` (or layer-appropriate shared module) instead of duplicating.

## UI row spacing rule
- For dense form rows (e.g., scan/clear actions inside input rows), prefer `GestureDetector`/`InkWell` with tight constraints over `IconButton`.
- Reason: `IconButton` adds default tap target/padding that can change row height/baseline and break visual alignment.
