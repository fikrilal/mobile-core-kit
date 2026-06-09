#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
reporter="$script_dir/mobile_failure_report.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

create_run() {
  local name="$1"
  local status="$2"
  local result="$3"
  local failure_message="$4"
  local commands_json="${5:-[]}"
  local run_dir="$temp_dir/$name"

  mkdir -p "$run_dir/maestro/artifacts"
  if [[ -n "$failure_message" ]]; then
    printf '<testsuite><testcase name="%s" status="%s"><failure>%s</failure></testcase></testsuite>\n' \
      "$name" "$status" "$failure_message" > "$run_dir/maestro/junit.xml"
  else
    printf '<testsuite><testcase name="%s" status="%s"></testcase></testsuite>\n' \
      "$name" "$status" > "$run_dir/maestro/junit.xml"
  fi
  printf 'result=%s\n' "$result" > "$run_dir/status.env"
  printf '%s\n' "$commands_json" > "$run_dir/maestro/artifacts/commands-test.json"
  : > "$run_dir/maestro/runner.log"
  : > "$run_dir/maestro/maestro.log"
  : > "$run_dir/maestro/device.log"
  printf '%s\n' "$run_dir"
}

assert_classification() {
  local run_dir="$1"
  local expected_class="$2"
  local expected_domain="$3"

  "$reporter" "$run_dir" >/dev/null
  jq -e \
    --arg failure_class "$expected_class" \
    --arg failure_domain "$expected_domain" \
    '.failureClass == $failure_class and .failureDomain == $failure_domain' \
    "$run_dir/failure_report.json" >/dev/null
  grep -Fq -- "- Failure domain: \`$expected_domain\`" "$run_dir/failure_report.md"
}

passed_run="$(create_run passed SUCCESS passed "")"
assert_classification "$passed_run" none none

device_run="$(create_run device ERROR failed "Device setup failed")"
echo "device emulator-5554 is not connected" > "$device_run/maestro/device.log"
assert_classification "$device_run" device_not_ready infrastructure

cleanup_backend_run="$(create_run cleanup-backend ERROR failed "Cleanup failed")"
cat > "$cleanup_backend_run/maestro/runner.log" <<'EOF'
Fixture cleanup failed
HTTP 500
EOF
assert_classification "$cleanup_backend_run" fixture_cleanup_failed backend

cleanup_harness_run="$(create_run cleanup-harness ERROR failed "Cleanup failed")"
echo "Session revocation failed" > "$cleanup_harness_run/maestro/runner.log"
assert_classification "$cleanup_harness_run" fixture_cleanup_failed test_harness

backend_run="$(create_run backend ERROR failed "Request failed")"
echo "HTTP 401" > "$backend_run/maestro/runner.log"
assert_classification "$backend_run" backend_http_error backend

input_commands='[
  {
    "command": {"tapOnElement": {"selector": {"textRegex": "Home"}}},
    "metadata": {
      "status": "FAILED",
      "error": {"message": "Home is visible"},
      "viewHierarchy": {
        "root": {
          "attributes": {"text": "Email"},
          "children": [{"attributes": {"text": "Password"}}]
        }
      }
    }
  }
]'
input_run="$(create_run input ERROR failed "Home is visible" "$input_commands")"
assert_classification "$input_run" input_not_applied test_harness

selector_run="$(create_run selector ERROR failed "Assertion is false: id: login_button is visible")"
assert_classification "$selector_run" selector_mismatch test_harness

navigation_run="$(create_run navigation ERROR failed "App did not navigate to expected screen")"
assert_classification "$navigation_run" app_did_not_navigate app

unknown_run="$(create_run unknown ERROR failed "Unexpected failure")"
echo "Fixture cleanup completed" > "$unknown_run/maestro/runner.log"
assert_classification "$unknown_run" unknown unknown

echo "Mobile failure report contract tests passed."
