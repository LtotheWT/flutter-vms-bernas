#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS=(
  "$ROOT_DIR/lib/presentation/pages/visitor_check_in_page.dart"
  "$ROOT_DIR/lib/presentation/pages/permanent_contractor_check_page.dart"
)

PATTERN='suffixIcon[[:space:]]*:[[:space:]]*IconButton[[:space:]]*\('

for target in "${TARGETS[@]}"; do
  if rg -n "$PATTERN" "$target" >/dev/null; then
    echo "Dense input suffix uses IconButton in: $target"
    echo "Use CompactSuffixTapIcon (or GestureDetector/InkWell) instead."
    exit 1
  fi
done

echo "Dense input suffix guard passed."
