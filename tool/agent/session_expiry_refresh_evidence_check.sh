#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || fail 'Unable to locate repository root.'
cd "$repo_root"

artifacts_dir=""
runner_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --artifacts-dir)
      [[ $# -ge 2 ]] || fail '--artifacts-dir requires a value.'
      artifacts_dir="$2"
      runner_args+=( "$1" "$2" )
      shift 2
      ;;
    *)
      runner_args+=( "$1" )
      shift
      ;;
  esac
done

if [[ -z "$artifacts_dir" ]]; then
  artifacts_dir="_artifacts/mobile/session-expiry-refresh-$(date '+%Y%m%d_%H%M%S')"
  runner_args+=( --artifacts-dir "$artifacts_dir" )
fi
mkdir -p "$artifacts_dir"

proxy_port="${SESSION_REFRESH_PROXY_PORT:-4100}"
upstream="${SESSION_REFRESH_UPSTREAM:-http://127.0.0.1:4000}"
status_file="$artifacts_dir/session_refresh_fixture.json"
proxy_log="$artifacts_dir/session_refresh_fixture.log"
proxy_pid=""

cleanup() {
  local original_status=$?
  trap - EXIT INT TERM
  if [[ -n "$proxy_pid" ]] && kill -0 "$proxy_pid" 2>/dev/null; then
    kill "$proxy_pid"
    wait "$proxy_pid" 2>/dev/null || true
  fi
  exit "$original_status"
}
trap cleanup EXIT INT TERM

python3 "$script_dir/session_refresh_fault_proxy.py" \
  --listen-port "$proxy_port" \
  --upstream "$upstream" \
  --status-file "$status_file" \
  >"$proxy_log" 2>&1 &
proxy_pid=$!

for _ in {1..50}; do
  [[ -s "$status_file" ]] && break
  kill -0 "$proxy_pid" 2>/dev/null || fail 'Session refresh proxy exited during startup.'
  sleep 0.1
done
[[ -s "$status_file" ]] || fail 'Session refresh proxy did not become ready.'

export MOBILE_EVIDENCE_DEV_API_BASE_URL="http://10.0.2.2:${proxy_port}/v1"
set +e
"$script_dir/auth_fixture_evidence_check.sh" \
  --flow .maestro/flows/session/session_expiry_refresh.yaml \
  "${runner_args[@]}"
runner_status=$?
set -e

fixture_valid="$(
  jq -r '
    .injected401 == true
    and .refreshCount == 1
    and .replayObserved == true
    and (.sessionId | type == "string" and length > 0)
  ' "$status_file"
)"
if [[ "$fixture_valid" != true ]]; then
  echo "ERROR: Refresh fixture did not observe one complete refresh/replay cycle." >&2
  jq . "$status_file" >&2
  exit 1
fi

exit "$runner_status"
