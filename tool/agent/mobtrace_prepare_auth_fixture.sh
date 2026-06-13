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

cleanup_created_identity() {
  [[ "$identity_provisioned" -eq 1 ]] || return 0

  local login_body login_status access_token refresh_token sessions_status
  login_body="$(
    jq -nc \
      --arg email "$fixture_email" \
      --arg password "$fixture_password" \
      --arg deviceId mobtrace-prepare-cleanup \
      --arg deviceName mobtrace-prepare-cleanup \
      '{email:$email,password:$password,deviceId:$deviceId,deviceName:$deviceName}'
  )"
  login_status="$(api_request POST /auth/password/login "$login_body" '' "$response_file")"
  [[ "$login_status" == 200 ]] || return 0
  access_token="$(jq -r '.data.accessToken // empty' "$response_file")"
  refresh_token="$(jq -r '.data.refreshToken // empty' "$response_file")"
  [[ -n "$access_token" && -n "$refresh_token" ]] || return 0

  sessions_status="$(api_request GET /me/sessions '' "$access_token" "$response_file")"
  if [[ "$sessions_status" == 200 ]]; then
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
      [[ "$revoke_status" == 204 ]] || true
    done < <(
      jq -r \
        '.data[] | select(.status == "active" and .current != true) | .id' \
        "$response_file"
    )
  fi

  logout_refresh_token "$refresh_token" "$response_file" || true
}

on_exit() {
  local status=$?
  trap - EXIT INT TERM
  if [[ "$status" -ne 0 ]]; then
    cleanup_created_identity || true
  fi
  rm -f "$response_file" "$secondary_response_file"
  exit "$status"
}

require_command adb
require_command apkanalyzer
require_command curl
require_command jq

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || fail 'Unable to locate repository root.'
cd "$repo_root"

device_id="${MOBTRACE_DEVICE_ID:-emulator-5554}"
app_file="${MOBTRACE_APP_FILE:-build/app/outputs/flutter-apk/app-dev-debug.apk}"
fixture_api_base_url="${FIXTURE_API_BASE_URL:-http://localhost:4000/v1}"
fixture_api_base_url="${fixture_api_base_url%/}"

[[ -s "$app_file" ]] || fail "APK is missing or empty: $app_file"
if ! adb devices | awk 'NR > 1 && $2 == "device" {print $1}' | grep -Fxq "$device_id"; then
  fail "Device '$device_id' is not connected and ready."
fi

app_id="$(apkanalyzer manifest application-id "$app_file" 2>/dev/null | tr -d '[:space:]')"
[[ -n "$app_id" ]] || fail "Unable to inspect application ID from APK: $app_file"

response_file="$(mktemp)"
secondary_response_file="$(mktemp)"
fixture_email="mobtrace-auth-$(date +%s)-$RANDOM@example.test"
fixture_password="Mck!$(date +%s)${RANDOM}Aa9z"
identity_provisioned=0
trap on_exit EXIT INT TERM

echo "Installing $app_file for $app_id on $device_id"
adb -s "$device_id" install -r -t "$app_file" >/dev/null
if ! adb -s "$device_id" shell pm path "$app_id" | grep -q '^package:'; then
  fail "Installed package does not match APK application ID: $app_id"
fi

register_body="$(
  jq -nc \
    --arg email "$fixture_email" \
    --arg password "$fixture_password" \
    --arg deviceId mobtrace-setup \
    --arg deviceName mobtrace-setup \
    '{email:$email,password:$password,deviceId:$deviceId,deviceName:$deviceName}'
)"
register_status="$(api_request POST /auth/password/register "$register_body" '' "$response_file")"
case "$register_status" in
  200|201) ;;
  *) fail "Fixture registration failed with HTTP $register_status." ;;
esac

setup_access_token="$(jq -r '.data.accessToken // empty' "$response_file")"
setup_refresh_token="$(jq -r '.data.refreshToken // empty' "$response_file")"
[[ -n "$setup_access_token" && -n "$setup_refresh_token" ]] ||
  fail 'Fixture registration returned no tokens.'
identity_provisioned=1

profile_body='{"profile":{"displayName":"Maestro Fixture","givenName":"Maestro","familyName":"Fixture"}}'
profile_status="$(api_request PATCH /me "$profile_body" "$setup_access_token" "$response_file")"
[[ "$profile_status" == 200 ]] ||
  fail "Fixture profile completion failed with HTTP $profile_status."
logout_refresh_token "$setup_refresh_token" "$response_file" ||
  fail 'Fixture setup logout failed.'

jq -n \
  --arg appId "$app_id" \
  --arg email "$fixture_email" \
  --arg password "$fixture_password" \
  '{
    environment: {
      APP_ID: $appId,
      MAESTRO_TEST_EMAIL: $email,
      MAESTRO_TEST_PASSWORD: $password
    }
  }' > "$MOBTRACE_HOOK_OUTPUT"

trap - EXIT INT TERM
rm -f "$response_file" "$secondary_response_file"
