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
