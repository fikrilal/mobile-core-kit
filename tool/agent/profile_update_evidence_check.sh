#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export AUTH_FIXTURE_RESTORE_PROFILE=1

exec "$script_dir/auth_fixture_evidence_check.sh" \
  --flow .maestro/flows/account/profile_update.yaml \
  "$@"
