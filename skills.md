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
  - Form-based input is required (`TextFormField`)
  - Field shares common label/suffix behavior

- Steps:
  1. Replace `TextField`/`TextFormField` with `AppTextFormField`.
  2. Pass label, controller, and validators.
  3. Use `readOnly + onTap` for picker-driven inputs.
  4. Use `obscureText` for passwords.

- Constraints / Failures:
  - Obscured fields must be single-line.
  - Multiline should not be combined with `obscureText`.

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
  - Dropdowns are form-bound and require validation or labels

- Steps:
  1. Replace `DropdownButtonFormField` with `AppDropdownFormField`.
  2. Build items using `AppDropdownMenuItem(value, label)`.
  3. Pass `validator` for required selections.

- Constraints / Failures:
  - Items must be explicit when value != label.
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
  - Multi-step form uses `Stepper`

- Steps:
  1. Validate current step before moving forward.
  2. Block progression and show errors when invalid.
  3. On final step, validate and submit.
  4. Show confirmation (e.g., bottom sheet) and success feedback.

- Constraints / Failures:
  - Skipping validation can lead to incomplete data.
  - Stepper must not advance when required fields are missing.

- Must NOT:
  - Perform async submit without validating all required inputs.

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
  - List-based UI with multiple selectable items

- Steps:
  1. Track selected items in a `Set`.
  2. Provide select-all toggle based on list size.
  3. Enable bulk action only when selection is non-empty.
  4. Confirm destructive actions before mutation.
  5. Update lists and clear selection after action.

- Constraints / Failures:
  - Bulk actions must not run with empty selection.
  - Ensure selection state stays in sync with list mutations.

- Must NOT:
  - Delete without confirmation.

## Skill: login_usecase_flow
**Title:** Login Use Case Flow (DDD + Riverpod)

- Purpose:
  Authenticate via UI → controller → use case → repository → data source.

- Inputs:
  - User ID and password strings

- Outputs:
  - Loading state, error state, and navigation on success

- Preconditions:
  - Providers are wired for data source, repository, and use case

- Steps:
  1. UI triggers controller login and shows loading state.
  2. Controller calls use case with value objects.
  3. Use case calls repository and data source.
  4. On success, navigate to home; on error, show message.

- Constraints / Failures:
  - Empty credentials throw validation errors.
  - Navigation should occur only after successful completion.

- Must NOT:
  - Bypass value object validation.

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

- Constraints / Failures:
  - Skipping recent changes leads to undocumented workflows.
  - Overlapping skills reduce clarity and reuse.

- Must NOT:
  - Add skills unrelated to executable workflows.
