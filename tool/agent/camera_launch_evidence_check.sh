#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export AUTH_FIXTURE_CLEAR_PROFILE_IMAGE=1

exec "$script_dir/auth_fixture_evidence_check.sh" \
  --flow .maestro/flows/account/camera_capture_upload_cleanup.yaml \
  "$@"
