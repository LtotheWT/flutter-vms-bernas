---
name: vms-bernas
description: "Workflows and engineering patterns for the vms_bernas Flutter app: layered domain/data/presentation implementation, Riverpod state flows, GoRouter routing, reusable UI extraction, async option forms, API/repository error mapping, and test-focused refactors."
---

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
  - Ensure all pages are available and importable.
  - Ensure route paths are unique.
  - Use GoRouter as the routing mechanism.

- Steps:
  1. Declare route name/path constants in `router.dart`.
  2. Register all pages in a single `GoRouter` instance.
  3. Configure `initialLocation` to the splash route.
  4. Trigger timed navigation from splash to `/login`.
  5. Use home menu tiles to push to feature routes.

- Examples: See `references/examples.md` for repo-based snippets.
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
  - Use when a pattern appears in 2 or more places.
  - Ensure widget behavior is deterministic.
  - Use styling from ThemeData.

- Steps:
  1. Identify duplicated UI structure or interaction.
  2. Extract it into a standalone widget.
  3. Pass state and callbacks via constructor parameters.
  4. Keep widgets stateless unless local UI state is required.
  5. Use the widget consistently wherever the pattern appears.

- Examples:
  - See `references/examples.md` for repo-based snippets.
  - Shared field/select rows: `lib/presentation/widgets/labeled_form_rows.dart`
  - Shared searchable bottom sheet: `lib/presentation/widgets/searchable_option_sheet.dart`
- Constraints / Failures:
  - Do not own business logic in widgets.
  - Do not perform navigation in widgets.
  - Do not read repositories or use cases in widgets.

- Must NOT:
  - Hardcode values that should be configurable.
  - Duplicate extracted widgets under different names.
  - Keep page-private copies of shared select row or searchable bottom sheet widgets.

## Skill: reusable_form_field_wrapper
**Title:** Reusable Form Field Wrapper (AppTextFormField)

- Purpose:
  Standardize text input fields with consistent styling and behavior.

- Inputs:
  - `label`, `controller`, `focusNode`
  - `keyboardType`, `textInputAction`, `readOnly`
  - `obscureText`, `minLines`, `maxLines`
  - `suffixIcon`, `validator`, `onTap`

- Outputs:
  - Consistent `TextFormField` rendering across screens
  - Centralized input rules (e.g., read-only date fields)

- Preconditions:
  - Use when form-based input is required.
  - Use when fields share common label/suffix behavior.

- Steps:
  1. Replace `TextField`/`TextFormField` with `AppTextFormField`.
  2. Pass label, controller, and validators.
  3. Use `readOnly + onTap` for picker-driven inputs.
  4. Use `obscureText` for passwords.

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Keep obscured fields single-line.
  - Avoid combining multiline with `obscureText`.

- Must NOT:
  - Bypass validators for required fields.
  - Use for non-form inputs that need raw `TextField`.

## Skill: reusable_dropdown_wrapper
**Title:** Reusable Dropdown Wrapper (AppDropdownFormField)

- Purpose:
  Standardize dropdowns and their menu items across pages.

- Inputs:
  - `label`, `value`, `items`
  - `onChanged`, `validator`, `hint`, `isExpanded`

- Outputs:
  - Consistent `DropdownButtonFormField` styling
  - Reusable item construction via `AppDropdownMenuItem`

- Preconditions:
  - Use when dropdowns are form-bound and require validation or labels.

- Steps:
  1. Replace `DropdownButtonFormField` with `AppDropdownFormField`.
  2. Build items using `AppDropdownMenuItem(value, label)`.
  3. Pass `validator` for required selections.

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Make items explicit when value != label.
  - Use non-const lists when labels are dynamic.

- Must NOT:
  - Hardcode duplicated dropdowns in multiple pages.

## Skill: stepper_validation_flow
**Title:** Stepper Validation Flow

- Purpose:
  Gate step transitions and submission with validation.

- Inputs:
  - Step index and form state
  - Required field values

- Outputs:
  - Controlled step navigation
  - Submission review and success feedback

- Preconditions:
  - Use with multi-step forms that use `Stepper`.

- Steps:
  1. Validate the current step before moving forward.
  2. Block progression and show errors when invalid.
  3. On final step, validate and submit.
  4. Show confirmation (e.g., bottom sheet) and success feedback.

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Skipping validation can lead to incomplete data.
  - Do not advance when required fields are missing.

- Must NOT:
  - Perform async submit without validating all required inputs.

## Skill: dependent_async_dropdowns
**Title:** Dependent Async Dropdowns (Entity → Site → Department)

- Purpose:
  Model dependent dropdowns with async option loading and deterministic reset behavior.

- Inputs:
  - Parent selection value
  - Async loader (Provider/UseCase)
  - Child field controller + form field key

- Outputs:
  - Child options updated after parent change
  - Child selection reset and disabled while loading
  - Loading/error helper text with retry behavior on error

- Preconditions:
  - Parent field has a stable value (nullable until selected).
  - Child field uses controllers for text + selection state.

- Steps:
  1. Expose a `FutureProvider.family` (or UseCase) keyed by parent value.
  2. On parent change: clear child controller, reset child form field, clear child state.
  3. While loading: disable child field and show helper text.
  4. On error: show an error hint and allow tap-to-retry (invalidate/reload provider); avoid validation errors.
  5. Re-enable normal selection when options are loaded.
  6. If backend returns blank child options, keep them visible only when needed and map blank selection to null for required validation.
  7. Use `lib/presentation/state/reference_providers.dart` as the default home for shared reference option providers reused across screens.

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Avoid firing child validation when parent changes.
  - Do not keep stale child selections after parent change.
  - If retry is supported, child field must remain tappable on error state.

- Must NOT:
  - Load child options without a parent selection.
  - Leave child enabled while async load is in-flight.
  - Treat blank API options as valid required selections unless explicitly intended.
  - Define duplicate entity/site/department/visitor-type option providers in feature-specific files.

## Skill: idempotent_submit_lifecycle
**Title:** Idempotent Submit Lifecycle

- Purpose:
  Keep retries for the same logical submit request idempotent and stable.

- Inputs:
  - Form controller state
  - Submit action trigger
  - Payload change/reset events

- Outputs:
  - Stable idempotency key reuse for retries
  - Key reset when payload changes
  - Key propagated to repository/datasource request headers

- Preconditions:
  - Submit flow is asynchronous and can be retried after timeout/error.
  - Idempotency header is supported by backend.

- Steps:
  1. Generate UUID in controller on first submit attempt.
  2. Persist the key in form state.
  3. Reuse the key on retries while payload is unchanged.
  4. Clear key when payload changes or clear/reset is invoked.
  5. Pass key through usecase to repository/datasource headers.

- Constraints / Failures:
  - Generating a new key for every retry defeats idempotency behavior.

- Must NOT:
  - Regenerate key for the same logical retry.
  - Create idempotency key in repository when retry continuity is required.

## Skill: searchable_dropdown_menu_anchor
**Title:** Searchable Dropdown (MenuAnchor + TextField)

- Purpose:
  Provide searchable dropdowns that avoid keyboard overlap and support custom menu layout.

- Inputs:
  - `entries` list
  - `menuHeight`, `menuItemHeight`
  - `openUpwards` flag
  - `TextEditingController`

- Outputs:
  - MenuAnchor-based dropdown with search
  - Width matched to anchor
  - Scroll-to-selected on open
  - Selected row highlight

- Preconditions:
  - Use when built-in DropdownMenu is insufficient.
  - Keep a single reusable widget for consistency.

- Steps:
  1. Use `MenuAnchor` with a `TextFormField` anchor.
  2. Filter entries on text input; show “No results” when empty.
  3. Size menu to `menuHeight` and match anchor width.
  4. Position above anchor when keyboard is present.
  5. Sync invalid input back to last valid selection.

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Avoid layout drift from custom offsets.
  - Keep filtering case-insensitive.

- Must NOT:
  - Allow arbitrary text that isn’t in entries.
  - Duplicate menu logic per page.

## Skill: form_reset_with_controllers
**Title:** Form Reset with Controllers

- Purpose:
  Reset form state consistently when fields are controller-backed.

- Inputs:
  - Form keys
  - TextEditingControllers
  - Dependent dropdown controllers

- Outputs:
  - Clean form + selection state
  - Cleared controller text
  - Reset validation state

- Preconditions:
  - Use when forms have multiple controllers and dependent fields.

- Steps:
  1. Call `FormState.reset()` on active form keys.
  2. Clear all controllers (including dropdown controllers).
  3. Reset dependent field keys (if needed) and touched flags.
  4. Clear provider state via controller notifier.

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Resetting only form state does not clear controller text.

- Must NOT:
  - Leave controller text after reset.
  - Forget to clear dependent fields.

## Skill: selection_bulk_actions
**Title:** Selection + Bulk Actions Pattern

- Purpose:
  Enable select-all, per-item selection, and bulk actions.

- Inputs:
  - Item list and selected ID/index set
  - Action callbacks (delete, confirm)

- Outputs:
  - Selection counts
  - Bulk action enable/disable
  - Confirmed bulk removal

- Preconditions:
  - Use with list-based UI that supports multiple selection.

- Steps:
  1. Track selected items in a `Set`.
  2. Provide select-all toggle based on list size.
  3. Enable bulk action only when selection is non-empty.
  4. Confirm destructive actions before mutation.
  5. Update lists and clear selection after action.

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Do not run bulk actions with empty selection.
  - Keep selection state in sync with list mutations.

## Skill: skills_gap_review
**Title:** Skills Gap Review

- Purpose:
  Check whether new or updated workflows should be captured in `skills.md`.

- Inputs:
  - Recent code changes or feature descriptions
  - Existing `skills.md` entries

- Outputs:
  - List of missing or outdated skills
  - Decision to add/update/remove skills

- Preconditions:
  - `skills.md` exists and is accessible

- Steps:
  1. Identify new features or repeated workflows added since last update.
  2. Map those workflows to existing skills (if any).
  3. Flag gaps where no skill exists or where a skill is outdated.
  4. Add or revise skills using the standard format.
  5. Verify no duplicate or overlapping skills remain.

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Skipping recent changes leads to undocumented workflows.
  - Overlapping skills reduce clarity and reuse.

- Must NOT:
  - Add skills unrelated to executable workflows.

## Skill: report_table_listing_pattern
**Title:** Report Table Listing Pattern

- Purpose:
  Build report screens that mirror the Invitation Listing pattern (filters + results + empty state),
  while allowing action buttons to vary by report (e.g., Search/Export).

- Inputs:
  - Filter fields (entity/site/date range/ids/etc.)
  - Action buttons (report-specific)
  - Result rows (table or list)

- Outputs:
  - Filter UI (often in a sheet or top section)
  - Results view with empty state
  - Report-specific actions

- Preconditions:
  - Report requires tabular or list-based results
  - Filters are required before querying

- Steps:
  1. Reuse filter layout patterns from Invitation Listing.
  2. Provide Search and any report-specific actions.
  3. Render results using the Invitation Listing list style (cards + expansion).
  4. Match Invitation Listing spacing (list padding, header spacing, card margins).
  5. Show empty state when no records exist (centered text).

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Buttons must reflect report needs; do not hardcode global actions.
  - Keep filter UX consistent with Invitation Listing for familiarity.
  - Do not add extra outer borders around the results list.

- Must NOT:
  - Diverge from the established listing structure without a clear reason.

## Skill: repository_failure_mapping
**Title:** Repository Failure Mapping (Data -> Domain)

- Purpose:
  Normalize datasource/transport failures into domain-safe failures so usecases and presentation logic stay infrastructure-agnostic.

- Inputs:
  - Repository methods calling remote/local datasources
  - Transport/parse exceptions (Dio, payload issues, unknown runtime errors)
  - Domain failure model (or equivalent typed error contract)

- Outputs:
  - Consistent domain-level failure mapping per repository method
  - Usecases free of transport exception branching
  - Predictable error contract for providers/pages

- Preconditions:
  - Repository implementation exists in `lib/data/repositories/`.
  - Datasource calls may throw transport or parsing exceptions.
  - Domain layer has (or is adding) explicit failure types.

- Steps:
  1. Wrap datasource calls in a single mapping boundary in repository methods.
  2. Map known transport failures (status/auth/network/timeout) to domain failures.
  3. Map malformed payload/parsing failures to validation or data-contract failures.
  4. Map unexpected failures to `unknown` domain failure.
  5. Ensure usecases expose only mapped domain failures.
  6. Add repository tests for success + each mapped failure class.

- Examples:
  - Invitation flow: `lib/data/repositories/invitation_repository_impl.dart`
  - Reference flow: `lib/data/repositories/reference_repository_impl.dart`
- Constraints / Failures:
  - Letting `DioException` escape repository boundaries leaks infrastructure concerns upward.
  - Per-method ad hoc mapping causes inconsistent UX and retry behavior.

- Must NOT:
  - Branch on Dio exception types in presentation/state layers.
  - Return raw datasource exceptions from usecases.

## Skill: async_option_orchestration
**Title:** Riverpod Async Option Orchestration (Load/Error/Retry/Cache)

- Purpose:
  Provide deterministic option-loading behavior across dependent form selectors with shared loading, error, retry, and cache semantics.

- Inputs:
  - Parent selections (entity/site/department/etc.)
  - Riverpod providers/usecases for reference option loading
  - Current form selection state and touched flags

- Outputs:
  - Consistent async option UX across all invitation/listing forms
  - Deterministic reset behavior when parent fields change
  - Explicit retry path and cache freshness policy

- Preconditions:
  - Shared option providers live in `lib/presentation/state/reference_providers.dart`.
  - Feature-specific form state uses controller/notifier in `lib/presentation/state/`.

- Steps:
  1. Use shared async option helpers for `loading/data/error` branching.
  2. Reset dependent child selections immediately when parent changes.
  3. Disable child selectors while loading; show helper text for loading/error.
  4. Support retry by invalidating and re-watching the option provider.
  5. Add cache policy (timestamp + TTL) for stable reference data.
  6. Add tests for load, error, retry success, and stale-cache refresh.

- Examples:
  - Shared helpers: `lib/presentation/state/async_option_helpers.dart`
  - Form integration: `lib/presentation/state/invitation_add_providers.dart`
- Constraints / Failures:
  - Keeping stale child selection after parent updates produces invalid payloads.
  - Inconsistent loading/error UI across selectors confuses users.

- Must NOT:
  - Duplicate shared option providers inside page-specific files.
  - Trigger required-field validation while a dependent selector is still loading.

## Skill: shared_form_widget_contracts
**Title:** Shared Form Widget Contracts + Widget Test Harness

- Purpose:
  Lock reusable form row/sheet behavior behind explicit UI contracts and widget tests so refactors in feature pages do not regress core interactions.

- Inputs:
  - Shared form widgets (`labeled_form_rows.dart`, `searchable_option_sheet.dart`)
  - Feature pages composing those widgets (e.g., invitation add/listing)
  - Expected UX contract (labels, required marker, helper/error text, selection callback)

- Outputs:
  - Stable widget-level contracts for shared form components
  - Reduced duplication in pages
  - Widget tests guarding critical rendering and selection behavior

- Preconditions:
  - Repeated row/sheet patterns already exist in `lib/presentation/widgets/`.
  - Critical form flows have known edge cases (empty options, filter/no-result, disabled state).

- Steps:
  1. Define each shared widget contract (inputs + state rendering behavior).
  2. Ensure feature pages compose shared widgets instead of local variants.
  3. Add widget tests for label/helper/error/required combinations.
  4. Add sheet tests for filtering, empty state, and selection callback.
  5. Keep widget ownership limited to presentation concerns.

- Examples:
  - `lib/presentation/widgets/labeled_form_rows.dart`
  - `lib/presentation/widgets/searchable_option_sheet.dart`
- Constraints / Failures:
  - Missing widget tests makes iterative UI refactors risky.
  - Page-private clones of shared widgets drift and fragment UX.

- Must NOT:
  - Embed business/usecase/repository logic inside shared widgets.
  - Maintain duplicate selector implementations for the same interaction pattern.

## Skill: auth_router_guard_reliability
**Title:** Auth Session + Router Guard Reliability

- Purpose:
  Centralize auth-driven routing decisions and verify them with tests so splash/login/home transitions remain deterministic as auth/session logic evolves.

- Inputs:
  - Auth session provider state (`loading/authenticated/unauthenticated`)
  - Route path constants and GoRouter redirect rules
  - Session persistence/token bootstrap behavior

- Outputs:
  - Single redirect decision path in router configuration
  - State-driven splash/login/home transitions
  - Test-covered guard behavior for startup/logout/expired session

- Preconditions:
  - Auth state providers exist in `lib/presentation/state/auth_session_providers.dart`.
  - Router setup exists in `lib/presentation/app/router.dart`.

- Steps:
  1. Define one canonical auth state source for routing decisions.
  2. Keep all auth redirects in router-level logic, not inside pages.
  3. Ensure splash behavior reflects auth bootstrap state, not timer-only navigation.
  4. Add tests for authenticated cold start, unauthenticated cold start, logout redirect, and expired token handling.
  5. Ensure bootstrap failures safely resolve to unauthenticated state.

- Examples:
  - `lib/presentation/app/router.dart`
  - `lib/presentation/state/auth_session_providers.dart`
  - `lib/presentation/pages/splash_page.dart`
- Constraints / Failures:
  - Timer-only splash navigation can route authenticated users to the wrong destination.
  - Scattered redirect logic across pages causes route flicker and inconsistent guards.

- Must NOT:
  - Duplicate auth guard conditions in multiple page widgets.
  - Depend on UI timers as the source of truth for auth transitions.
