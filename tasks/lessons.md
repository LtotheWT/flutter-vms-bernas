# Lessons

## 2026-03-01
- In dense input rows, avoid `IconButton` for trailing actions by default.
- Use compact `GestureDetector`/`InkWell` wrappers so text field height and baseline stay aligned with adjacent rows.
- If trailing action must be reused, expose it as a widget slot and keep spacing controlled by the caller.
- If the same parse/format helper appears in more than one file, extract it into a shared utility (`lib/core/`) and reuse it immediately.

## 2026-03-04
- If requirement says "in-page only", avoid adding modal behavior even as temporary UX; wire existing action buttons (e.g., History) to the in-page section directly.
