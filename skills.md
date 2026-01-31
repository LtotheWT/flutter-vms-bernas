# Reusable Skills (vms_bernas)

## Skill: App Routing and Navigation Shell
**Title:** App Routing and Navigation Shell

- Purpose:
  Centralize navigation paths and provide entry-point navigation flow.

- Inputs:
  - Route names and paths
  - Page widgets to register
  - Initial location and navigation triggers

- Outputs:
  - GoRouter configuration
  - Splash to login navigation
  - Home menu navigation to feature routes

- Preconditions:
  - All pages are available and importable
  - Route paths are unique
  - GoRouter is the routing mechanism

- Steps:
  1. Declare route name/path constants in `router.dart`.
  2. Register all pages in a single `GoRouter` instance.
  3. Configure `initialLocation` to the splash route.
  4. Trigger timed navigation from splash to `/login`.
  5. Use home menu tiles to push to feature routes.

- Constraints / Failures:
  - Time-based splash navigation has no auth gating.
  - Routes are static; no typed parameters or guards.
  - Navigation relies on `context.go`/`context.push`.

- Must NOT:
  - Define duplicate route paths.
  - Perform business logic in route builders.

## Skill: reusable_widget_extraction
**Title:** Reusable Widget Extraction and Usage

- Purpose:
  Create and consume reusable UI widgets to reduce duplication and ensure consistency.

- Inputs:
  - Repeated UI patterns (fields, rows, cards, buttons)
  - Required state and callbacks
  - Theme and layout context

- Outputs:
  - Stateless or minimally stateful reusable widgets
  - Consistent UI behavior across screens

- Preconditions:
  - Pattern appears in 2 or more places
  - Widget behavior is deterministic
  - Styling comes from ThemeData

- Steps:
  1. Identify duplicated UI structure or interaction.
  2. Extract it into a standalone widget.
  3. Pass state and callbacks via constructor parameters.
  4. Keep widgets stateless unless local UI state is required.
  5. Use the widget consistently wherever the pattern appears.

- Constraints / Failures:
  - Widgets must not own business logic.
  - Widgets must not perform navigation.
  - Widgets must not read repositories or use cases.

- Must NOT:
  - Hardcode values that should be configurable.
  - Duplicate extracted widgets under different names.
