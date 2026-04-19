#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mapfile -t presentation_dirs < <(find lib/features -type d -path '*/presentation' | sort)

if [ ${#presentation_dirs[@]} -eq 0 ]; then
  echo "No presentation directories found under lib/features." >&2
  exit 2
fi

# Flutter presentation duplication detection is intentionally separate from the
# main duplication harness. This profile focuses on narrow, high-value patterns
# such as repeated cubit validation/failure helpers and repeated form-page
# sections, while keeping noisy generic widget-tree duplication out of scope.
npx --yes jscpd \
  "${presentation_dirs[@]}" \
  --config .jscpd.presentation.json \
  --silent

dart tool/filter_duplication_report.dart \
  --profile presentation \
  --report .tmp/jscpd-presentation/jscpd-report.json \
  --allowlist tool/presentation_duplication_allowlist.json
