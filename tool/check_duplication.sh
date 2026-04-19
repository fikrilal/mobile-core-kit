#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

# Duplication detection focuses on high-ROI maintainability duplication:
# parsers, formatters, mappers, translation helpers, normalization helpers,
# and small workflow tails. Presentation-heavy paths stay out of scope for now
# because that signal is still noisier and better handled in a later phase.
npx --yes jscpd \
  lib/features \
  lib/core/foundation \
  lib/core/runtime \
  lib/core/infra \
  lib/navigation \
  --config .jscpd.json \
  --silent

dart tool/filter_duplication_report.dart \
  --report .tmp/jscpd-phase1/jscpd-report.json \
  --allowlist tool/duplication_allowlist.json
