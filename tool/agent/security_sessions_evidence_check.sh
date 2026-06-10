#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "$script_dir/auth_fixture_evidence_check.sh" \
  --flow .maestro/flows/account/security_sessions.yaml \
  "$@"
