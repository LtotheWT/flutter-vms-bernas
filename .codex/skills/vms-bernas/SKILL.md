---
name: vms-bernas
description: "Workflows and UI patterns for the vms_bernas Flutter app: GoRouter routing setup, reusable widget extraction, form field and dropdown wrappers, stepper validation, and selection/bulk actions. Use when implementing or refactoring these patterns in this codebase."
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

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Do not own business logic in widgets.
  - Do not perform navigation in widgets.
  - Do not read repositories or use cases in widgets.

- Must NOT:
  - Hardcode values that should be configurable.
  - Duplicate extracted widgets under different names.

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
  - Loading/error helper text

- Preconditions:
  - Parent field has a stable value (nullable until selected).
  - Child field uses controllers for text + selection state.

- Steps:
  1. Expose a `FutureProvider.family` (or UseCase) keyed by parent value.
  2. On parent change: clear child controller, reset child form field, clear child state.
  3. While loading: disable child field and show helper text.
  4. On error: keep child disabled and show error hint; avoid validation errors.
  5. Re-enable child when options are loaded.

- Examples: See `references/examples.md` for repo-based snippets.
- Constraints / Failures:
  - Avoid firing child validation when parent changes.
  - Do not keep stale child selections after parent change.

- Must NOT:
  - Load child options without a parent selection.
  - Leave child enabled while async load is in-flight.

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
