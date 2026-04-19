#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

# Phase 1 duplicate detection focuses on high-ROI maintainability duplication:
# parsers, formatters, mappers, normalization helpers, and small shared logic.
# It intentionally excludes presentation-heavy paths for now because that signal
# is noisier and better treated as a later phase.
npx --yes jscpd \
  lib/features \
  lib/core/foundation \
  lib/core/runtime \
  lib/core/infra \
  lib/navigation \
  --config .jscpd.json \
  --silent

dart tool/filter_duplication_report.dart \
  --report .tmp/jscpd-phase1/jscpd-report.json
