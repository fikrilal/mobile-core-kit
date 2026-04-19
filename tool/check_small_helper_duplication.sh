#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Small helper duplication detection intentionally uses lower thresholds than
# the broader duplication profiles. The filter only keeps helper-shaped signals
# such as field-error helpers, formatters, display helpers, parsers, and
# normalization helpers.
npx --yes jscpd \
  lib/features \
  lib/core/foundation \
  lib/core/runtime \
  lib/navigation \
  --config .jscpd.small_helpers.json \
  --silent

dart tool/filter_duplication_report.dart \
  --profile small_helpers \
  --report .tmp/jscpd-small-helpers/jscpd-report.json \
  --allowlist tool/small_helper_duplication_allowlist.json
