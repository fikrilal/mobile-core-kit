#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  tool/agent/auth_fixture_evidence_check.sh --flow <path> --device <id> [Maestro runner options]

Environment:
  FIXTURE_API_BASE_URL  Backend API root (default: http://localhost:4000/v1).

The wrapper provisions a run-scoped account, runs the selected Maestro flow,
revokes all sessions, and removes generated credentials from text artifacts.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 command not found."
}

api_request() {
  local method="$1"
  local path="$2"
  local body="$3"
  local access_token="$4"
  local output_file="$5"
  local args=(
    --silent
    --show-error
    --output "$output_file"
    --write-out '%{http_code}'
    --request "$method"
  )
  if [[ -n "$access_token" ]]; then
    args+=( --header "Authorization: Bearer $access_token" )
  fi
  if [[ -n "$body" ]]; then
    args+=( --header 'Content-Type: application/json' --data "$body" )
  fi
  curl "${args[@]}" "$fixture_api_base_url$path"
}

expect_status() {
  local actual="$1"
  local expected="$2"
  local operation="$3"
  [[ "$actual" == "$expected" ]] || fail "$operation failed with HTTP $actual."
}

logout_refresh_token() {
  local refresh_token="$1"
  local output_file="$2"
  local body status
  body="$(jq -nc --arg refreshToken "$refresh_token" '{refreshToken:$refreshToken}')"
  status="$(api_request POST /auth/logout "$body" '' "$output_file")"
  [[ "$status" == 204 ]]
}

cleanup_identity() {
  [[ "$identity_provisioned" -eq 1 ]] || return 0
  cleanup_started=1

  local login_body login_status access_token refresh_token
  login_body="$(
    jq -nc \
      --arg email "$fixture_email" \
      --arg password "$fixture_password" \
      --arg deviceId maestro-cleanup \
      --arg deviceName maestro-cleanup \
      '{email:$email,password:$password,deviceId:$deviceId,deviceName:$deviceName}'
  )"
  login_status="$(api_request POST /auth/password/login "$login_body" '' "$response_file")"
  if [[ "$login_status" != 200 ]]; then
    echo "ERROR: Cleanup login failed with HTTP $login_status." >&2
    return 1
  fi
  access_token="$(jq -er '.data.accessToken' "$response_file")" || {
    echo 'ERROR: Cleanup login returned no access token.' >&2
    return 1
  }
  refresh_token="$(jq -er '.data.refreshToken' "$response_file")" || {
    echo 'ERROR: Cleanup login returned no refresh token.' >&2
    return 1
  }
  secrets+=( "$access_token" "$refresh_token" )

  local sessions_status
  sessions_status="$(api_request GET /me/sessions '' "$access_token" "$response_file")"
  if [[ "$sessions_status" != 200 ]]; then
    echo "ERROR: Cleanup session listing failed with HTTP $sessions_status." >&2
    return 1
  fi

  local session_id revoke_status
  while IFS= read -r session_id; do
    [[ -n "$session_id" ]] || continue
    revoke_status="$(
      api_request \
        POST \
        "/me/sessions/$session_id/revoke" \
        '' \
        "$access_token" \
        "$secondary_response_file"
    )"
    if [[ "$revoke_status" != 204 ]]; then
      echo "ERROR: Session revocation failed with HTTP $revoke_status." >&2
      return 1
    fi
  done < <(
    jq -r \
      '.data[] | select(.status == "active" and .current != true) | .id' \
      "$response_file"
  )

  logout_refresh_token "$refresh_token" "$response_file" || {
    echo 'ERROR: Cleanup-session logout failed.' >&2
    return 1
  }

  login_status="$(api_request POST /auth/password/login "$login_body" '' "$response_file")"
  if [[ "$login_status" != 200 ]]; then
    echo "ERROR: Cleanup verification login failed with HTTP $login_status." >&2
    return 1
  fi
  access_token="$(jq -er '.data.accessToken' "$response_file")" || return 1
  refresh_token="$(jq -er '.data.refreshToken' "$response_file")" || return 1
  secrets+=( "$access_token" "$refresh_token" )

  sessions_status="$(api_request GET /me/sessions '' "$access_token" "$response_file")"
  if [[ "$sessions_status" != 200 ]]; then
    echo "ERROR: Cleanup verification listing failed with HTTP $sessions_status." >&2
    return 1
  fi
  if [[ "$(jq '[.data[] | select(.status == "active" and .current == true)] | length' "$response_file")" != 1 ]]; then
    echo 'ERROR: Cleanup verifier session is not uniquely current.' >&2
    return 1
  fi
  if [[ "$(jq '[.data[] | select(.status == "active")] | length' "$response_file")" != 1 ]]; then
    echo 'ERROR: Active sessions remain after cleanup revocation.' >&2
    return 1
  fi
  logout_refresh_token "$refresh_token" "$response_file" || {
    echo 'ERROR: Cleanup verifier logout failed.' >&2
    return 1
  }
}

redact_artifacts() {
  [[ -d "$artifacts_dir" ]] || return 0
  local secret file
  for secret in "${secrets[@]}"; do
    [[ -n "$secret" ]] || continue
    while IFS= read -r file; do
      sed -i "s|$secret|[REDACTED]|g" "$file"
    done < <(rg -IlF -- "$secret" "$artifacts_dir" || true)
  done

  for secret in "${secrets[@]}"; do
    [[ -n "$secret" ]] || continue
    if rg -IFq -- "$secret" "$artifacts_dir"; then
      echo "ERROR: Generated fixture secret remains in text artifacts." >&2
      return 1
    fi
  done
}

on_exit() {
  local original_status=$?
  trap - EXIT INT TERM
  local cleanup_status=0

  if [[ "$cleanup_started" -eq 0 ]]; then
    cleanup_identity || cleanup_status=$?
  fi
  redact_artifacts || cleanup_status=$?
  rm -f "$response_file" "$secondary_response_file"

  if [[ "$cleanup_status" -ne 0 ]]; then
    echo "ERROR: Fixture cleanup or artifact redaction failed." >&2
    exit "$cleanup_status"
  fi
  exit "$original_status"
}

require_command curl
require_command adb
require_command jq
require_command rg

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || fail 'Unable to locate repository root.'
cd "$repo_root"

runner_args=()
artifacts_dir=""
device_id=""
flow_path=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --flow)
      [[ $# -ge 2 ]] || fail '--flow requires a value.'
      flow_path="$2"
      shift 2
      ;;
    --artifacts-dir)
      [[ $# -ge 2 ]] || fail '--artifacts-dir requires a value.'
      artifacts_dir="$2"
      runner_args+=( "$1" "$2" )
      shift 2
      ;;
    --device)
      [[ $# -ge 2 ]] || fail '--device requires a value.'
      device_id="$2"
      runner_args+=( "$1" "$2" )
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *)
      runner_args+=( "$1" )
      shift
      ;;
  esac
done
[[ -n "$flow_path" ]] || fail '--flow is required.'
[[ -e "$flow_path" ]] || fail "Selected flow not found: $flow_path"
[[ -n "$device_id" ]] || fail '--device is required.'
if ! adb devices | awk 'NR > 1 && $2 == "device" {print $1}' | grep -Fxq "$device_id"; then
  fail "Device '$device_id' is not connected and ready."
fi
if [[ -z "$artifacts_dir" ]]; then
  flow_name="$(basename "$flow_path" .yaml)"
  artifacts_dir="_artifacts/mobile/${flow_name}-$(date '+%Y%m%d_%H%M%S')"
  runner_args+=( --artifacts-dir "$artifacts_dir" )
fi

fixture_api_base_url="${FIXTURE_API_BASE_URL:-http://localhost:4000/v1}"
fixture_api_base_url="${fixture_api_base_url%/}"
fixture_email="maestro-auth-$(date +%s)-$RANDOM@example.test"
fixture_password="Mck!$(date +%s)${RANDOM}Aa9z"
identity_provisioned=0
cleanup_started=0
secrets=( "$fixture_email" "$fixture_password" )
response_file="$(mktemp)"
secondary_response_file="$(mktemp)"
trap on_exit EXIT INT TERM

register_body="$(
  jq -nc \
    --arg email "$fixture_email" \
    --arg password "$fixture_password" \
    --arg deviceId maestro-setup \
    --arg deviceName maestro-setup \
    '{email:$email,password:$password,deviceId:$deviceId,deviceName:$deviceName}'
)"
register_status="$(
  api_request POST /auth/password/register "$register_body" '' "$response_file"
)"
setup_access_token="$(jq -r '.data.accessToken // empty' "$response_file")"
setup_refresh_token="$(jq -r '.data.refreshToken // empty' "$response_file")"
if [[ -n "$setup_access_token" && -n "$setup_refresh_token" ]]; then
  identity_provisioned=1
fi
case "$register_status" in
  200|201) ;;
  *) fail "Fixture registration failed with HTTP $register_status." ;;
esac
[[ "$identity_provisioned" -eq 1 ]] || fail 'Fixture registration returned no tokens.'
secrets+=( "$setup_access_token" "$setup_refresh_token" )

profile_body='{"profile":{"displayName":"Maestro Fixture","givenName":"Maestro","familyName":"Fixture"}}'
profile_status="$(api_request PATCH /me "$profile_body" "$setup_access_token" "$response_file")"
expect_status "$profile_status" 200 'Fixture profile completion'
logout_refresh_token "$setup_refresh_token" "$response_file" || fail 'Fixture setup logout failed.'

export MAESTRO_TEST_EMAIL="$fixture_email"
export MAESTRO_TEST_PASSWORD="$fixture_password"

tool/agent/maestro_evidence_check.sh \
  "${runner_args[@]}" \
  --flow "$flow_path"
