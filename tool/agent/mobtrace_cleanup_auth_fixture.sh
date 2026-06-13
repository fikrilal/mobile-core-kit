#!/usr/bin/env bash
set -euo pipefail

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

logout_refresh_token() {
  local refresh_token="$1"
  local output_file="$2"
  local body status
  body="$(jq -nc --arg refreshToken "$refresh_token" '{refreshToken:$refreshToken}')"
  status="$(api_request POST /auth/logout "$body" '' "$output_file")"
  [[ "$status" == 204 ]]
}

require_command curl
require_command jq

fixture_api_base_url="${FIXTURE_API_BASE_URL:-http://localhost:4000/v1}"
fixture_api_base_url="${fixture_api_base_url%/}"
fixture_email="${MAESTRO_TEST_EMAIL:-}"
fixture_password="${MAESTRO_TEST_PASSWORD:-}"
[[ -n "$fixture_email" && -n "$fixture_password" ]] ||
  fail 'Fixture credentials were not exported by prepare hook.'

response_file="$(mktemp)"
secondary_response_file="$(mktemp)"
trap 'rm -f "$response_file" "$secondary_response_file"' EXIT

login_body="$(
  jq -nc \
    --arg email "$fixture_email" \
    --arg password "$fixture_password" \
    --arg deviceId mobtrace-cleanup \
    --arg deviceName mobtrace-cleanup \
    '{email:$email,password:$password,deviceId:$deviceId,deviceName:$deviceName}'
)"
login_status="$(api_request POST /auth/password/login "$login_body" '' "$response_file")"
[[ "$login_status" == 200 ]] ||
  fail "Cleanup login failed with HTTP $login_status."

access_token="$(jq -r '.data.accessToken // empty' "$response_file")"
refresh_token="$(jq -r '.data.refreshToken // empty' "$response_file")"
[[ -n "$access_token" && -n "$refresh_token" ]] ||
  fail 'Cleanup login returned no tokens.'

sessions_status="$(api_request GET /me/sessions '' "$access_token" "$response_file")"
[[ "$sessions_status" == 200 ]] ||
  fail "Cleanup session listing failed with HTTP $sessions_status."

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
  [[ "$revoke_status" == 204 ]] ||
    fail "Session revocation failed with HTTP $revoke_status."
done < <(
  jq -r \
    '.data[] | select(.status == "active" and .current != true) | .id' \
    "$response_file"
)

logout_refresh_token "$refresh_token" "$response_file" ||
  fail 'Cleanup logout failed.'
