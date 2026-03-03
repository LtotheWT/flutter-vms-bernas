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
