# TODO

## 2026-03-04 - Visitor gallery in-page integration
- [x] Add visitor gallery entity and repository methods for list/photo retrieval.
- [x] Add datasource/repository implementation for `/wmsws/Visitor/gallery-list/{invitationId}` and `/wmsws/Visitor/photo/{photoId}`.
- [x] Add gallery providers with in-memory photo cache in visitor check-in providers.
- [x] Replace summary gallery placeholders with API-backed gallery section below summary.
- [x] Change History action to navigate to in-page gallery section instead of opening a modal.
- [x] Add data/state/widget tests for gallery list/photo integration path.
- [x] Run verification (`flutter analyze` on touched files).

## Review
- Gallery is now invitation-level and shown only in-page under Visitor Summary.
- History button now switches to Summary tab and scrolls to gallery section.
- API photo failures are non-blocking; per-tile placeholder remains.
- Verification: `flutter analyze` passed for touched production files.
- Note: local `flutter test` run is currently blocked by Flutter SDK/toolchain mismatch in this environment (semantics compile errors in Flutter framework sources).

## 2026-03-04 - Whitelist check search integration
- [x] Add whitelist domain entities, repository contract, and search use case.
- [x] Add whitelist request/response/item DTOs with status normalization.
- [x] Add whitelist remote datasource and repository implementation for `/wmsws/Whitelist/search`.
- [x] Add whitelist Riverpod providers/controller with initial load and filter apply flows.
- [x] Add new whitelist check page + filter page for both check-in/check-out modes.
- [x] Wire home menu and router routes for Whitelist Check-In/Out.
- [x] Add data/domain/state/page tests for whitelist feature.
- [x] Run verification (`flutter analyze` + targeted `flutter test` suites).

## Review (Whitelist)
- Initial page load now auto-searches using first non-empty entity from `/wmsws/Ref/entity` and route-derived `CURRENT_TYPE`.
- Filter supports required entity and optional vehicle plate, IC, and status; unselected status is still sent as empty string.
- Check-In and Check-Out share the same page and provider flow; only `CURRENT_TYPE` changes (`I` vs `O`).
- No bulk select/delete UI is included for whitelist listing.
- Verification:
  - `flutter analyze` passed for all touched whitelist files.
  - `flutter test` passed for new whitelist model/datasource/repository/usecase/state/page tests.

## 2026-03-05 - Whitelist detail navigation refactor
- [x] Add whitelist detail domain entity and repository/usecase contract.
- [x] Add whitelist detail response DTO and remote datasource GET method for `/wmsws/Whitelist/{entity}/{vehiclePlate}`.
- [x] Extend whitelist repository implementation with detail retrieval and token guard.
- [x] Add whitelist detail providers/controller for fetch lifecycle.
- [x] Add dedicated whitelist detail page with required fields and placeholder confirm action.
- [x] Refactor whitelist list cards from `ExpansionTile` to tappable cards navigating to detail page.
- [x] Add router detail route with typed `state.extra` args and hook list navigation.
- [x] Extend/add tests for detail DTO/datasource/repository/usecase/providers/pages and rerun verification.

## Review (Whitelist Detail)
- Whitelist list rows now open a dedicated details screen; expansion interaction is removed.
- Details screen always fetches latest record via detail API on open.
- Confirm button is visible and enabled for both modes, showing mode-specific placeholder snackbar until submit API is provided.
- Row tap guards missing identifiers (`entity`/`vehiclePlate`) and shows a brief snackbar instead of navigating.
- Verification:
  - Targeted `flutter analyze` passed for all touched whitelist detail/list files.
  - Targeted whitelist `flutter test` suite passed (data/domain/state/page coverage).

## 2026-03-05 - Whitelist detail submit integration (check-in/check-out)
- [x] Add whitelist submit domain entities and use cases.
- [x] Extend whitelist repository interface and implementation for submit check-in/check-out with idempotency support.
- [x] Add whitelist submit request/response DTOs.
- [x] Extend whitelist remote datasource for `/wmsws/Whitelist/check-in` and `/wmsws/Whitelist/check-out`.
- [x] Add whitelist detail controller submit flow with session validation and stable idempotency key lifecycle.
- [x] Update whitelist detail page confirm action to call real submit API with mode-based label and snackbar.
- [x] Add/extend tests for DTOs, datasource, repository, usecases, providers, and details page submit behavior.
- [x] Run verification (`flutter analyze` + targeted `flutter test` suites).

## Review (Whitelist Detail Submit)
- Confirm on whitelist details now calls real submit endpoint by mode (`I` -> check-in, `O` -> check-out).
- Payload uses session fields (`entity`, `defaultSite`, `defaultGate`, `username`) plus detail `vehiclePlate`.
- Idempotency key is reused for retries of the same payload signature and reset when signature changes.
- Success/failure feedback is shown with snackbar while staying on the details page.
- Verification:
  - `flutter analyze lib/presentation/pages/whitelist_detail_page.dart lib/presentation/state/whitelist_detail_providers.dart lib/data/datasources/whitelist_remote_data_source.dart lib/data/repositories/whitelist_repository_impl.dart lib/domain/repositories/whitelist_repository.dart`
  - `flutter test test/data/models/whitelist_submit_request_dto_test.dart test/data/models/whitelist_submit_response_dto_test.dart test/domain/usecases/submit_whitelist_check_in_usecase_test.dart test/domain/usecases/submit_whitelist_check_out_usecase_test.dart test/data/datasources/whitelist_remote_data_source_test.dart test/data/repositories/whitelist_repository_impl_test.dart test/presentation/state/whitelist_detail_providers_test.dart test/presentation/pages/whitelist_detail_page_test.dart test/presentation/pages/whitelist_check_page_test.dart test/presentation/state/whitelist_check_providers_test.dart test/domain/usecases/search_whitelist_usecase_test.dart test/domain/usecases/get_whitelist_detail_usecase_test.dart`

## 2026-03-05 - Refresh whitelist list after successful detail submit
- [x] Return refresh signal from whitelist detail route when check-in/out submit succeeds.
- [x] Refresh whitelist list page when detail route pops with refresh signal.
- [x] Add widget coverage for list refresh-on-return behavior.
- [x] Run targeted verify for whitelist check/detail pages.

## Review (Whitelist Refresh on Return)
- Whitelist detail page now tracks successful submit and pops with a boolean refresh result.
- Whitelist list page listens for detail route result and re-runs whitelist search when result is `true`.
- Behavior applies for both check-in and check-out submit success paths.
- Verification:
  - `flutter analyze lib/presentation/pages/whitelist_detail_page.dart lib/presentation/pages/whitelist_check_page.dart`
  - `flutter test test/presentation/pages/whitelist_check_page_test.dart test/presentation/pages/whitelist_detail_page_test.dart test/presentation/state/whitelist_detail_providers_test.dart`

## 2026-03-05 - Dashboard API integration with entity-only filter
- [x] Add dashboard summary domain entities and `getDashboardSummary` repository/usecase contracts.
- [x] Add dashboard response DTO parsing for `VisitorIO`/`ContrIO`/`WhitelistIO` with entity-match and fallback-zero behavior.
- [x] Extend reference remote datasource and repository implementation for `GET /wmsws/Ref/dashboard?entity=...`.
- [x] Add dashboard Riverpod controller/state for initial load and entity re-fetch.
- [x] Refactor report dashboard page to use live API data and app-bar filter page with entity-only selection.
- [x] Keep existing KPI tap navigation to dashboard list with selected entity context.
- [x] Add/extend tests for dashboard DTO, datasource, repository, usecase, state, and page behavior.
- [x] Run verification (`flutter analyze` + targeted `flutter test` suites).

## Review (Dashboard API Integration)
- Dashboard KPI cards now render live counts from `/wmsws/Ref/dashboard` instead of hardcoded values.
- Entity defaults to the first non-empty option from `/wmsws/Ref/entity`, and initial dashboard fetch happens automatically.
- Dashboard filter now follows the same pattern as other screens (app bar filter action + dedicated filter page) with entity-only selection.
- Error/loading/retry states are wired through provider state; missing entity shows a clear actionable error.
- Verification:
  - `flutter analyze lib/presentation/pages/report_dashboard_page.dart lib/presentation/state/report_dashboard_providers.dart lib/data/datasources/reference_remote_data_source.dart lib/data/repositories/reference_repository_impl.dart lib/data/models/dashboard_io_metric_dto.dart lib/data/models/dashboard_summary_response_dto.dart lib/domain/entities/dashboard_io_metric_entity.dart lib/domain/entities/dashboard_summary_entity.dart lib/domain/repositories/reference_repository.dart lib/domain/usecases/get_dashboard_summary_usecase.dart`
  - `flutter test test/data/models/dashboard_io_metric_dto_test.dart test/data/models/dashboard_summary_response_dto_test.dart test/data/datasources/reference_remote_data_source_test.dart test/data/repositories/reference_repository_impl_dashboard_test.dart test/domain/usecases/get_dashboard_summary_usecase_test.dart test/presentation/state/report_dashboard_providers_test.dart test/presentation/pages/report_dashboard_page_test.dart test/domain/usecases/get_permanent_contractor_info_usecase_test.dart test/domain/usecases/submit_permanent_contractor_check_in_usecase_test.dart test/domain/usecases/submit_permanent_contractor_check_out_usecase_test.dart test/domain/usecases/reference_usecases_test.dart test/presentation/state/permanent_contractor_check_providers_test.dart test/presentation/state/permanent_contractor_check_providers_image_test.dart test/presentation/pages/permanent_contractor_check_page_test.dart`

## 2026-03-05 - Employee check-in/out integration
- [x] Add employee domain entities, repository contract, and use cases for lookup + submit.
- [x] Add employee lookup/submit DTOs, datasource methods, and repository implementation for `/wmsws/Employee/*`.
- [x] Add employee Riverpod Notifier controller/state with idempotency lifecycle and session validation.
- [x] Add new Employee Check-In/Out page with check type toggle, scan/manual search, detail display, and confirm submit.
- [x] Extract reusable `CheckTypeSegmentedControl` widget and reuse in permanent contractor page.
- [x] Wire routes and home tiles for Employee Check-In/Out to the shared employee page with preselected mode.
- [x] Add data/domain/state/page tests for employee feature and run verification.

## Review (Employee Check-In/Out)
- Employee lookup now uses `GET /wmsws/Employee/{encodedCode}` and clears the scan/input field on successful lookup.
- Submit now calls live APIs by mode (`/wmsws/Employee/check-in` or `/wmsws/Employee/check-out`) with `Idempotency-Key`.
- Submit payload uses session `defaultSite/defaultGate/username` and loaded `EmployeeId`, with stable idempotency key reuse on retry.
- Details stay visible after submit and user feedback is shown via snackbar backend message/fallback.
- Verification:
  - `flutter analyze lib/presentation/pages/employee_check_page.dart lib/presentation/state/employee_check_providers.dart lib/data/datasources/employee_access_remote_data_source.dart lib/data/repositories/employee_access_repository_impl.dart lib/presentation/widgets/check_type_segmented_control.dart lib/presentation/pages/permanent_contractor_check_page.dart lib/presentation/app/router.dart lib/presentation/pages/home_page.dart lib/core/date_time_formats.dart`
  - `flutter test test/data/models/employee_info_response_dto_test.dart test/data/models/employee_submit_request_dto_test.dart test/data/models/employee_submit_response_dto_test.dart test/data/datasources/employee_access_remote_data_source_test.dart test/data/repositories/employee_access_repository_impl_test.dart test/domain/usecases/get_employee_info_usecase_test.dart test/domain/usecases/submit_employee_check_in_usecase_test.dart test/domain/usecases/submit_employee_check_out_usecase_test.dart test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart test/presentation/pages/permanent_contractor_check_page_test.dart`

## 2026-03-05 - Employee profile image integration
- [x] Extend employee repository/data source contracts for profile image bytes fetch (`GET /wmsws/Employee/{employeeId}/photo`).
- [x] Add employee image provider + in-memory cache in employee state providers.
- [x] Render profile photo slot in Employee Check-In/Out info card with fullscreen preview behavior.
- [x] Add/extend data/repository/widget tests for employee profile image.
- [x] Run targeted verification for touched employee files.

## Review (Employee Profile Image)
- Employee info card now shows profile photo using the same `RemotePhotoSlot` pattern as permanent contractor.
- Image fetch is lazy and cached in memory per employee id during provider lifecycle.
- Missing/404 image returns placeholder and does not block check-in/out flow.
- Tapping loaded profile photo opens fullscreen preview.
- Verification:
  - `flutter analyze lib/presentation/pages/employee_check_page.dart lib/presentation/state/employee_check_providers.dart lib/data/datasources/employee_access_remote_data_source.dart lib/data/repositories/employee_access_repository_impl.dart lib/domain/repositories/employee_access_repository.dart`
  - `flutter test test/data/datasources/employee_access_remote_data_source_test.dart test/data/repositories/employee_access_repository_impl_test.dart test/domain/usecases/get_employee_info_usecase_test.dart test/domain/usecases/submit_employee_check_in_usecase_test.dart test/domain/usecases/submit_employee_check_out_usecase_test.dart test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart`

## 2026-03-05 - Invitation Add user row session binding
- [x] Replace hardcoded `User` row value in Invitation Add basic info with persisted session username.
- [x] Add reusable `persistedSessionProvider` in auth session providers for UI-level session reads.
- [x] Verify invitation add/auth session touched files via analyzer.

## Review (Invitation Add User Row)
- Invitation Add `User` row now reads logged-in username from persisted session (`persistedSessionProvider`) instead of hardcoded text.
- While session is loading, UI shows `Loading...`; if unavailable, it falls back to `-`.
- Verification:
  - `flutter analyze lib/presentation/pages/invitation_add_page.dart lib/presentation/state/auth_session_providers.dart`

## 2026-03-05 - Invitation Add share encrypted URL on submit success
- [x] Extend invitation submission entity/DTO parsing to carry `InvitationId`, `CreatedAt`, `GUID`, and `encryptURL`.
- [x] Extend invitation add provider submit result mapping to expose optional `encryptUrl`/`invitationId`.
- [x] Trigger `share_plus` share sheet from Invitation Add page when submit succeeds with non-empty encrypted URL.
- [x] Add/extend targeted tests for DTO parsing and invitation add provider mapping.
- [x] Run targeted verification (`flutter analyze` + targeted `flutter test`).

## Review (Invitation Add Share URL)
- Invitation submit response now preserves optional backend detail fields (`InvitationId`, `CreatedAt`, `GUID`, `encryptURL`) through DTO -> domain -> provider mapping.
- Invitation Add page now opens native share sheet on successful submit when encrypted URL is present, then keeps existing success snackbar + form reset flow.
- Share failure is non-blocking: app shows `Invitation created, but unable to open share sheet.` and still clears the form.
- Verification:
  - `flutter analyze lib/domain/entities/invitation_submission_entity.dart lib/data/models/invitation_create_response_dto.dart lib/presentation/state/invitation_add_providers.dart lib/presentation/pages/invitation_add_page.dart`
  - `flutter test test/data/models/invitation_create_response_dto_test.dart test/presentation/state/invitation_add_providers_test.dart`

## 2026-03-06 - Visitor check-in physical tag mandatory
- [x] Enforce physical tag validation for selected visitors in check-in flow before submit API call.
- [x] Keep check-out behavior unchanged and preserve existing payload mapping.
- [x] Update check-in physical tag input affordance text from optional to required.
- [x] Add/extend visitor check-in widget tests for mandatory physical tag validation.
- [x] Run targeted verification (`flutter analyze` + relevant `flutter test`).

## Review (Visitor Physical Tag Mandatory)
- Check-in confirm now blocks submission when any selected eligible visitor has blank `Physical Tag` and shows `Physical Tag is required for selected visitors before check-in.`.
- Check-out submit path and payload behavior remain unchanged.
- Editable physical tag row now shows `Required` hint text for check-in rows.
- Added widget coverage for blocking submit when selected visitor has empty physical tag and asserting no check-in API call is made.
- Verification:
  - `flutter analyze lib/presentation/pages/visitor_check_in_page.dart test/presentation/pages/visitor_check_in_page_test.dart`
  - `flutter test test/presentation/pages/visitor_check_in_page_test.dart` *(blocked by local Flutter SDK/framework mismatch in semantics compile stage, same environment issue as prior runs).*

## 2026-03-06 - Visitor physical tag inline error + focus to first missing row
- [x] Add inline `Required` error support for `LabeledTextInputRow` and wire to visitor physical tag row.
- [x] Add per-row physical tag error/focus/card key maps and custom scroll controller on visitor check page.
- [x] On check-in confirm failure, mark missing selected rows inline and auto-switch/scroll/focus first missing row.
- [x] Clear inline physical tag error on value correction, scan fill, and deselection.
- [x] Extend visitor page widget tests for inline error/focus path and correction flow.
- [x] Run targeted verification (`flutter analyze` + relevant `flutter test`).

## Review (Visitor Physical Tag Inline Error + Focus)
- Check-in validation now marks missing selected physical tags with inline `Required` under each affected row.
- Confirm from Summary tab now auto-switches to Visitor List, scrolls to the first missing row, and focuses its physical tag input.
- Inline errors clear immediately when user types/scans a non-empty physical tag, and on row deselection.
- Shared `LabeledTextInputRow` now supports optional inline `errorText` for dense form rows.
- Verification:
  - `flutter analyze lib/presentation/widgets/labeled_form_rows.dart lib/presentation/pages/visitor_check_in_page.dart test/presentation/pages/visitor_check_in_page_test.dart`
  - `flutter test test/presentation/pages/visitor_check_in_page_test.dart` *(blocked by local Flutter SDK/framework mismatch in semantics compile stage, same environment issue as prior runs).*

## 2026-03-06 - Simplify missing-physical-tag focus scroll flow
- [x] Replace complex viewport/offset fallback logic with simple `ensureVisible` + coarse scroll fallback.
- [x] Keep behavior: switch to Visitor List tab, try ensureVisible first, then estimate offset when context is missing.
- [x] Keep code lightweight (no render viewport math).
- [x] Run targeted verification (`flutter analyze`).

## Review (Simplified EnsureVisible Flow)
- `_focusFirstMissingPhysicalTag` now uses a simple two-step approach: try `ensureVisible` first; if context is missing, do coarse index-based scroll and focus.
- This improves long-list behavior without reintroducing render viewport complexity.
- Render viewport math is removed; scroll behavior stays lightweight and maintainable.
- Verification:
  - `flutter analyze lib/presentation/pages/visitor_check_in_page.dart`

## 2026-03-06 - Scanner launch dedup via shared helper
- [x] Add shared scanner launcher helper for `MobileScannerPage` navigation with optional override hook.
- [x] Refactor employee check page scanner-open flow to use shared helper.
- [x] Refactor permanent contractor check page scanner-open flow to use shared helper.
- [x] Refactor visitor page QR and physical-tag scan flows to use shared helper.
- [x] Run targeted verification (`flutter analyze` + page test attempt).

## 2026-03-06 - Employee gallery GUID split by check type
- [x] Replace single employee gallery session GUID with stable per-mode GUID state.
- [x] Update employee page upload/gallery wiring to use the active mode GUID.
- [x] Extend employee state/page tests for mode-specific gallery restoration and isolation.
- [x] Run targeted verification (`flutter analyze` + employee tests attempt).

## Review (Employee Gallery GUID Split - Superseded)
- This temporary direction was later corrected because the backend gallery API is keyed only by session GUID, not by check type.
- The current behavior is documented in `Review (Employee Gallery GUID Semantics)` below.
- Verification:
  - `flutter analyze lib/presentation/state/employee_check_providers.dart lib/presentation/pages/employee_check_page.dart test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart`
  - `flutter test test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart` *(blocked by local Flutter SDK/framework mismatch in semantics compile stage, same environment issue as prior runs).*

## 2026-03-06 - Employee gallery GUID semantics correction
- [x] Revert employee gallery back to one stable page-session GUID shared by check-in and check-out toggle states.
- [x] Update employee page tests to assert gallery continuity across mode toggles.
- [x] Update project lessons to capture GUID semantics for session-scoped galleries.
- [x] Run targeted verification (`flutter analyze` + employee tests attempt).

## Review (Employee Gallery GUID Semantics)
- Employee gallery now uses one GUID for the whole Employee Check-In/Out page session, even when the user toggles between Check-In and Check-Out.
- Toggling mode no longer switches gallery buckets; uploaded photos remain visible across both modes during that page session.
- Existing employee submit idempotency and profile photo behavior remain unchanged.
- Verification:
  - `flutter analyze lib/presentation/state/employee_check_providers.dart lib/presentation/pages/employee_check_page.dart test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart`
  - `flutter test test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart`

## Review (Scanner Launch Helper Refactor)
- Added `/Users/wengthailim/Workspace/flutter_projects/vms_bernas/lib/presentation/services/mobile_scanner_launcher.dart` with `openMobileScanner(...)` and `ScannerLauncherOverride`.
- Employee, permanent contractor, and visitor pages now call the shared helper instead of duplicating `Navigator.push(MobileScannerPage)` blocks.
- Existing page-level test hooks (`scanLauncher`, `physicalTagScanLauncher`) are preserved by passing them as `overrideLauncher`.
- Scan behavior remains unchanged: page-level trim/empty guards and follow-up actions still happen at call sites.
- Verification:
  - `flutter analyze lib/presentation/services/mobile_scanner_launcher.dart lib/presentation/pages/employee_check_page.dart lib/presentation/pages/permanent_contractor_check_page.dart lib/presentation/pages/visitor_check_in_page.dart`
  - `flutter test test/presentation/pages/employee_check_page_test.dart test/presentation/pages/permanent_contractor_check_page_test.dart test/presentation/pages/visitor_check_in_page_test.dart` *(blocked by local Flutter SDK/framework mismatch in semantics compile stage, same environment issue as prior runs).*

## 2026-03-06 - Shared exception-prefix error message helper
- [x] Add shared core helper for exception-prefix stripping + fallback display message.
- [x] Refactor repeated `Exception:` normalization in presentation pages/providers to use shared helper.
- [x] Run targeted verification (`flutter analyze` on touched files).

## Review (Shared Exception Helper)
- Added shared utility `/Users/wengthailim/Workspace/flutter_projects/vms_bernas/lib/core/error_messages.dart` with `stripExceptionPrefix(...)` and `toDisplayErrorMessage(...)`.
- Replaced repeated inline `Exception:` parsing in 13 presentation files (pages + providers) with the shared helper, preserving existing fallback messages per flow.
- Removed duplicated private `_normalizeError` implementations from employee/whitelist detail/report dashboard providers.
- Added targeted helper tests in `/Users/wengthailim/Workspace/flutter_projects/vms_bernas/test/core/error_messages_test.dart`.
- Verification:
  - `flutter analyze lib/core/error_messages.dart lib/presentation/pages/invitation_add_page.dart lib/presentation/pages/invitation_listing_page.dart lib/presentation/pages/report_dashboard_page.dart lib/presentation/pages/visitor_check_in_page.dart lib/presentation/pages/whitelist_check_page.dart lib/presentation/state/employee_check_providers.dart lib/presentation/state/invitation_add_providers.dart lib/presentation/state/invitation_listing_providers.dart lib/presentation/state/permanent_contractor_check_providers.dart lib/presentation/state/report_dashboard_providers.dart lib/presentation/state/visitor_check_in_providers.dart lib/presentation/state/whitelist_check_providers.dart lib/presentation/state/whitelist_detail_providers.dart`
  - `flutter test test/core/error_messages_test.dart` *(blocked by local Flutter SDK/framework mismatch in semantics compile stage, same environment issue as prior runs).*

## 2026-03-06 - Whitelist detail photo session integration
- [x] Add whitelist photo domain/data contracts for gallery list, photo bytes, upload, and delete.
- [x] Extend whitelist detail state with session GUID, gallery providers, and upload/delete flows.
- [x] Extract shared photo upload sheet and deleteable gallery thumbnail widgets, then reuse from visitor + whitelist.
- [x] Update whitelist detail page with camera action, preview/upload flow, in-page gallery, and local append/remove behavior.
- [x] Add/extend targeted tests for whitelist photo DTOs, datasource/repository, providers, and detail page.
- [x] Run targeted verification (`flutter analyze` + relevant `flutter test`).

## Review (Whitelist Detail Photo Session)
- Whitelist details now generate one UUID photo-session GUID per page open and reuse it for both `gallery-list/{guid}` and `save-photo` during that page session.
- Whitelist details page now mirrors visitor photo UX: `Camera` opens capture, captured image shows in preview/upload bottom sheet, successful upload appends locally to the in-page gallery, and delete removes locally without refetch.
- Shared presentation pieces were extracted into `lib/presentation/widgets/photo_upload_bottom_sheet.dart` and `lib/presentation/widgets/gallery_photo_tile.dart`, and visitor photo upload/gallery thumbnail code was refactored to reuse them.
- Gallery layout is now standardized with shared `GridView.builder` behavior across visitor and whitelist via `lib/presentation/widgets/gallery_photo_grid.dart`.
- Gallery photos are loaded lazily from `/wmsws/Whitelist/photo/{photoId}`, cached in memory, open fullscreen on tap, and show non-blocking placeholder behavior on missing/error.
- Verification:
  - `flutter analyze lib/data/datasources/whitelist_remote_data_source.dart lib/data/repositories/whitelist_repository_impl.dart lib/domain/repositories/whitelist_repository.dart lib/presentation/pages/visitor_check_in_page.dart lib/presentation/pages/whitelist_detail_page.dart lib/presentation/state/photo_cache_helpers.dart lib/presentation/state/visitor_check_in_providers.dart lib/presentation/state/whitelist_detail_providers.dart test/data/datasources/whitelist_remote_data_source_test.dart test/data/repositories/whitelist_repository_impl_test.dart test/domain/usecases/get_whitelist_detail_usecase_test.dart test/domain/usecases/search_whitelist_usecase_test.dart test/domain/usecases/submit_whitelist_check_in_usecase_test.dart test/domain/usecases/submit_whitelist_check_out_usecase_test.dart test/domain/usecases/save_whitelist_photo_usecase_test.dart test/domain/usecases/delete_whitelist_photo_usecase_test.dart test/presentation/pages/whitelist_check_page_test.dart test/presentation/pages/whitelist_detail_page_test.dart test/presentation/state/whitelist_check_providers_test.dart test/presentation/state/whitelist_detail_providers_test.dart test/data/models/whitelist_gallery_item_dto_test.dart test/data/models/whitelist_save_photo_request_dto_test.dart test/data/models/whitelist_save_photo_response_dto_test.dart test/data/models/whitelist_delete_photo_response_dto_test.dart`
  - `flutter test test/data/models/whitelist_gallery_item_dto_test.dart test/data/models/whitelist_save_photo_request_dto_test.dart test/data/models/whitelist_save_photo_response_dto_test.dart test/data/models/whitelist_delete_photo_response_dto_test.dart test/data/datasources/whitelist_remote_data_source_test.dart test/data/repositories/whitelist_repository_impl_test.dart test/domain/usecases/get_whitelist_detail_usecase_test.dart test/domain/usecases/search_whitelist_usecase_test.dart test/domain/usecases/submit_whitelist_check_in_usecase_test.dart test/domain/usecases/submit_whitelist_check_out_usecase_test.dart test/domain/usecases/save_whitelist_photo_usecase_test.dart test/domain/usecases/delete_whitelist_photo_usecase_test.dart test/presentation/state/whitelist_check_providers_test.dart test/presentation/state/whitelist_detail_providers_test.dart test/presentation/pages/whitelist_check_page_test.dart test/presentation/pages/whitelist_detail_page_test.dart`

## 2026-03-06 - Standardize gallery layout with shared GridView
- [x] Extract shared gallery grid widget for photo galleries.
- [x] Use the shared grid layout in visitor gallery.
- [x] Use the shared grid layout in whitelist gallery.
- [x] Run targeted verification for touched gallery layout files.

## Review (Gallery Grid Standardization)
- Visitor and whitelist galleries now share the same grid layout wrapper in `lib/presentation/widgets/gallery_photo_grid.dart`.
- Both gallery screens now use `GridView.builder` with the same default 3-column square tile layout, removing the previous `GridView` vs `Wrap` mismatch.
- Tile UI remains shared through `lib/presentation/widgets/gallery_photo_tile.dart`; this change standardizes the surrounding layout, not just the thumbnail widget.
- Verification:
  - `flutter analyze lib/presentation/widgets/gallery_photo_grid.dart lib/presentation/pages/visitor_check_in_page.dart lib/presentation/pages/whitelist_detail_page.dart`
  - `flutter test test/presentation/pages/whitelist_detail_page_test.dart test/presentation/pages/visitor_check_in_page_test.dart` *(blocked by the existing local Flutter SDK/framework semantics mismatch in this environment).*

## 2026-03-06 - Employee gallery session integration
- [x] Add employee gallery/photo domain, DTO, datasource, repository, and usecase support.
- [x] Extend employee check state with page-session GUID, gallery providers, and upload/delete flows.
- [x] Update employee check page with camera action, upload preview flow, and in-page gallery using shared widgets.
- [x] Add/extend targeted tests for employee gallery DTOs, datasource/repository, state, and page behavior.
- [x] Run targeted verification (`flutter analyze` + relevant `flutter test`).

## Review (Employee Gallery Session)
- Employee Check-In/Out now has a page-session gallery GUID, generated once per page lifecycle and reused for `GET /wmsws/Employee/gallery-list/{guid}` and `POST /wmsws/Employee/save-photo`.
- Employee page keeps the existing profile photo card and adds a second in-page gallery card with `Camera`, upload preview, local append on success, fullscreen preview, and local delete without list refetch.
- Shared photo UX is reused instead of duplicated: `photo_upload_bottom_sheet.dart`, `gallery_photo_grid.dart`, `gallery_photo_tile.dart`, `camera_capture_service.dart`, and the shared memory-cache helpers.
- Gallery items are appended to the end of local state so the newest photo stays at the back, matching the existing gallery ordering rule.
- Verification:
  - `flutter analyze lib/domain/repositories/employee_access_repository.dart lib/domain/entities/employee_gallery_item_entity.dart lib/domain/entities/employee_save_photo_submission_entity.dart lib/domain/entities/employee_save_photo_result_entity.dart lib/domain/entities/employee_delete_photo_result_entity.dart lib/domain/usecases/save_employee_photo_usecase.dart lib/domain/usecases/delete_employee_gallery_photo_usecase.dart lib/data/models/employee_gallery_item_dto.dart lib/data/models/employee_save_photo_request_dto.dart lib/data/models/employee_save_photo_response_dto.dart lib/data/models/employee_delete_photo_response_dto.dart lib/data/datasources/employee_access_remote_data_source.dart lib/data/repositories/employee_access_repository_impl.dart lib/presentation/state/employee_check_providers.dart lib/presentation/pages/employee_check_page.dart test/data/models/employee_gallery_item_dto_test.dart test/data/models/employee_save_photo_request_dto_test.dart test/data/models/employee_save_photo_response_dto_test.dart test/data/models/employee_delete_photo_response_dto_test.dart test/data/datasources/employee_access_remote_data_source_test.dart test/data/repositories/employee_access_repository_impl_test.dart test/domain/usecases/get_employee_info_usecase_test.dart test/domain/usecases/submit_employee_check_in_usecase_test.dart test/domain/usecases/submit_employee_check_out_usecase_test.dart test/domain/usecases/save_employee_photo_usecase_test.dart test/domain/usecases/delete_employee_gallery_photo_usecase_test.dart test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart`
  - `flutter test test/data/models/employee_gallery_item_dto_test.dart test/data/models/employee_save_photo_request_dto_test.dart test/data/models/employee_save_photo_response_dto_test.dart test/data/models/employee_delete_photo_response_dto_test.dart test/data/datasources/employee_access_remote_data_source_test.dart test/data/repositories/employee_access_repository_impl_test.dart test/domain/usecases/get_employee_info_usecase_test.dart test/domain/usecases/submit_employee_check_in_usecase_test.dart test/domain/usecases/submit_employee_check_out_usecase_test.dart test/domain/usecases/save_employee_photo_usecase_test.dart test/domain/usecases/delete_employee_gallery_photo_usecase_test.dart test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart` *(blocked by the existing local Flutter SDK/framework semantics mismatch in this environment).*

## 2026-03-06 - Employee post-submit session reset
- [x] Reset employee check state after successful submit while preserving the current check type.
- [x] Discard the old employee gallery GUID, clear its local gallery/session state, and generate a fresh GUID for the next session.
- [x] Clear loaded employee info after successful submit so camera/gallery require a fresh search.
- [x] Extend employee state/page tests for reset behavior and rerun targeted verification.

## Review (Employee Post-Submit Session Reset)
- Employee Check-In/Out now treats a successful submit as the end of the current employee session: loaded employee info is cleared immediately after success, while the current check type toggle remains unchanged.
- Successful submit now discards the old `photoSessionGuid`, clears employee gallery local additions/deletions and cached gallery photo bytes for that session where known, and generates a fresh GUID for the next search/upload cycle.
- Because `info` is cleared after success, the page hides the employee gallery card and camera action until the user performs a fresh employee search.
- Employee submit idempotency state is also reset after success so the next employee session starts cleanly.
- Verification:
  - `flutter analyze lib/presentation/state/employee_check_providers.dart lib/presentation/pages/employee_check_page.dart test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart`
  - `flutter test test/presentation/state/employee_check_providers_test.dart test/presentation/pages/employee_check_page_test.dart`

## 2026-03-06 - Whitelist submit success auto-return
- [x] Replace the whitelist detail page bool pop contract with a typed route result carrying refresh + success message.
- [x] Return to the whitelist list immediately after successful check-in/out submit.
- [x] Refresh the whitelist list and show the success snackbar on the list page after return.
- [x] Update whitelist detail/list widget tests and rerun targeted verification.

## Review (Whitelist Submit Auto-Return)
- Whitelist detail submit success now pops immediately with a typed `WhitelistDetailPageResult` instead of waiting for manual back navigation.
- The whitelist list page now consumes that result, refreshes using the existing filter state, and shows the backend/fallback success snackbar on the list page.
- Failed whitelist submit still stays on the detail page and shows the error snackbar there.
- Whitelist photo/gallery behavior is unchanged.
- Verification:
  - `flutter analyze lib/presentation/pages/whitelist_detail_page.dart lib/presentation/pages/whitelist_check_page.dart test/presentation/pages/whitelist_detail_page_test.dart test/presentation/pages/whitelist_check_page_test.dart`
  - `flutter test test/presentation/pages/whitelist_detail_page_test.dart test/presentation/pages/whitelist_check_page_test.dart`
