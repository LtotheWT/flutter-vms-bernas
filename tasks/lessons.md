# Lessons

## 2026-03-01
- In dense input rows, avoid `IconButton` for trailing actions by default.
- Use compact `GestureDetector`/`InkWell` wrappers so text field height and baseline stay aligned with adjacent rows.
- If trailing action must be reused, expose it as a widget slot and keep spacing controlled by the caller.
- If the same parse/format helper appears in more than one file, extract it into a shared utility (`lib/core/`) and reuse it immediately.

## 2026-03-04
- If requirement says "in-page only", avoid adding modal behavior even as temporary UX; wire existing action buttons (e.g., History) to the in-page section directly.
- For new Riverpod state changes, default to latest `NotifierProvider`/`AsyncNotifierProvider` APIs and avoid `legacy.dart` imports unless explicitly justified.

## 2026-03-05
- If the primary action is "open details then act", do not force `ExpansionTile`; use direct row navigation and keep details/actions on a dedicated page.
- When list item taps depend on identifiers, validate identifiers at tap time and fail with concise snackbar rather than navigating to a broken screen.
- When actions happen on a details page but list freshness matters, return a route result flag and refresh the list on pop rather than forcing immediate navigation.
- When implementing a new check-in/out screen that already has an existing profile-photo pattern in a similar feature, include photo parity upfront unless explicitly out of scope.
- Never hardcode logged-in user labels in form UI; read username from persisted session/provider and fallback safely.

## 2026-03-06
- If the same error-normalization branch (e.g., stripping `Exception:`) appears in multiple pages/providers, extract to `lib/core/` immediately and replace all duplicates in one pass.
- If a backend photo/gallery API is keyed only by GUID and not by mode, default to one stable GUID per page session; do not split by UI toggle unless the product explicitly requires separate galleries.
