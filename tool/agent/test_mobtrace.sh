#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runner="$script_dir/../../mobtrace"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

reporter_invocations="$temp_dir/reporter-invocations"
runner_invocations="$temp_dir/runner-invocations"
changed_files_fixture="$temp_dir/changed-files"
: > "$reporter_invocations"
: > "$runner_invocations"
: > "$changed_files_fixture"

fake_reporter="$temp_dir/fake_reporter"
cat > "$fake_reporter" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

run_dir="$1"
mkdir -p "$run_dir"
echo "$run_dir" >> "${MOBTRACE_REPORTER_INVOCATIONS:?}"
[[ "${FAKE_REPORTER_STATUS:-0}" -eq 0 ]] || exit "$FAKE_REPORTER_STATUS"

if [[ "${FAKE_RUN_RESULT:-failed}" == "passed" ]]; then
  cat > "$run_dir/failure_report.json" <<JSON
{
  "flow": "Login and logout with run-scoped identity",
  "status": "SUCCESS",
  "runResult": "passed",
  "failureClass": "none",
  "failureDomain": "none",
  "failedCommand": {"selector": ""},
  "suspiciousFiles": [],
  "suggestedAction": "No failure detected."
}
JSON
else
  cat > "$run_dir/failure_report.json" <<JSON
{
  "flow": "Login and logout with run-scoped identity",
  "status": "ERROR",
  "runResult": "failed",
  "failureClass": "selector_mismatch",
  "failureDomain": "test_harness",
  "failedCommand": {"selector": "auth_sign_in_pending_deep_link"},
  "suspiciousFiles": [
    ".maestro/flows/auth/login_logout.yaml",
    "lib/features/auth/presentation/login_page.dart"
  ],
  "suggestedAction": "Compare the expected selector with the final hierarchy text."
}
JSON
fi

echo "# Fake MobTrace report" > "$run_dir/failure_report.md"
EOF
chmod +x "$fake_reporter"

fake_runner="$temp_dir/fake_runner"
cat > "$fake_runner" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

artifacts_dir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --artifacts-dir)
      artifacts_dir="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

echo "$artifacts_dir" >> "${MOBTRACE_RUNNER_INVOCATIONS:?}"
mkdir -p "$artifacts_dir/maestro"
echo '<testsuite><testcase name="fake"/></testsuite>' > "$artifacts_dir/maestro/junit.xml"
exit "${FAKE_RUNNER_STATUS:-0}"
EOF
chmod +x "$fake_runner"

export MOBTRACE_REPORTER="$fake_reporter"
export MOBTRACE_LOGIN_LOGOUT_RUNNER="$fake_runner"
export MOBTRACE_SECURITY_SESSIONS_RUNNER="$fake_runner"
export MOBTRACE_CAMERA_LAUNCH_RUNNER="$fake_runner"
export MOBTRACE_MAESTRO_RUNNER="$fake_runner"
export MOBTRACE_ARTIFACTS_ROOT="$temp_dir/artifacts"
export MOBTRACE_REPORTER_INVOCATIONS="$reporter_invocations"
export MOBTRACE_RUNNER_INVOCATIONS="$runner_invocations"
export MOBTRACE_CHANGED_FILES_FILE="$changed_files_fixture"

failed_run="$MOBTRACE_ARTIFACTS_ROOT/failed"
mkdir -p "$failed_run/maestro"
echo '<testsuite><testcase name="failed"/></testsuite>' > "$failed_run/maestro/junit.xml"

failed_output="$("$runner" report latest)"
grep -Fq 'FAILED Login and logout with run-scoped identity' <<<"$failed_output"
grep -Fq 'Class: selector_mismatch' <<<"$failed_output"
grep -Fq 'Domain: test_harness' <<<"$failed_output"
grep -Fq 'Failed selector: auth_sign_in_pending_deep_link' <<<"$failed_output"
grep -Fq '1. .maestro/flows/auth/login_logout.yaml' <<<"$failed_output"
grep -Fq '2. lib/features/auth/presentation/login_page.dart' <<<"$failed_output"
grep -Fq 'Next action:' <<<"$failed_output"
grep -Fq "Report: $failed_run/failure_report.md" <<<"$failed_output"
grep -Fq "JSON: $failed_run/failure_report.json" <<<"$failed_output"

failed_summary="$("$runner" report latest --summary)"
[[ "$(wc -l <<<"$failed_summary")" -eq 1 ]]
jq -e \
  --arg report "$failed_run/failure_report.md" \
  --arg json "$failed_run/failure_report.json" \
  '
    keys == [
      "failedSelector",
      "failureClass",
      "failureDomain",
      "json",
      "report",
      "runResult",
      "status",
      "suggestedAction"
    ] and
    .status == "ERROR" and
    .runResult == "failed" and
    .failureClass == "selector_mismatch" and
    .failedSelector == "auth_sign_in_pending_deep_link" and
    .failureDomain == "test_harness" and
    .report == $report and
    .json == $json and
    .suggestedAction == "Compare the expected selector with the final hierarchy text."
  ' <<<"$failed_summary" >/dev/null
[[ -s "$failed_run/failure_report.md" ]]
[[ -s "$failed_run/failure_report.json" ]]

report_count_before_show="$(wc -l < "$reporter_invocations")"
set +e
show_output="$("$runner" show latest)"
show_status=$?
set -e
[[ "$show_status" -eq 0 ]]
[[ "$show_output" == "# Fake MobTrace report" ]]
[[ "$(wc -l < "$reporter_invocations")" -eq "$report_count_before_show" ]]
[[ ! -s "$runner_invocations" ]]

missing_report_run="$MOBTRACE_ARTIFACTS_ROOT/missing-report"
mkdir -p "$missing_report_run/maestro"
echo '<testsuite><testcase name="missing"/></testsuite>' > "$missing_report_run/maestro/junit.xml"
missing_output="$("$runner" show "$missing_report_run")"
[[ "$missing_output" == "# Fake MobTrace report" ]]
[[ "$(tail -n 1 "$reporter_invocations")" == "$missing_report_run" ]]
[[ ! -s "$runner_invocations" ]]

report_mtime="$(stat -c %Y "$failed_run/failure_report.md")"
touch -d "@$(( report_mtime + 1 ))" "$failed_run/maestro/junit.xml"
stale_count_before="$(wc -l < "$reporter_invocations")"
stale_output="$("$runner" show "$failed_run")"
[[ "$stale_output" == "# Fake MobTrace report" ]]
[[ "$(wc -l < "$reporter_invocations")" -eq $(( stale_count_before + 1 )) ]]
[[ "$(tail -n 1 "$reporter_invocations")" == "$failed_run" ]]
[[ ! -s "$runner_invocations" ]]

report_failure_run="$MOBTRACE_ARTIFACTS_ROOT/report-failure"
mkdir -p "$report_failure_run/maestro"
echo '<testsuite><testcase name="failure"/></testsuite>' > "$report_failure_run/maestro/junit.xml"
export FAKE_REPORTER_STATUS=9
set +e
"$runner" show "$report_failure_run" >/dev/null 2>&1
report_failure_status=$?
set -e
unset FAKE_REPORTER_STATUS
[[ "$report_failure_status" -eq 9 ]]
[[ ! -s "$runner_invocations" ]]

passed_run="$MOBTRACE_ARTIFACTS_ROOT/passed"
mkdir -p "$passed_run/maestro"
echo '<testsuite><testcase name="passed"/></testsuite>' > "$passed_run/maestro/junit.xml"
export FAKE_RUN_RESULT=passed

passed_output="$("$runner" report "$passed_run")"
grep -Fq 'PASSED Login and logout with run-scoped identity' <<<"$passed_output"
grep -Fq 'Class: none' <<<"$passed_output"
grep -Fq 'Domain: none' <<<"$passed_output"
if grep -Fq 'Failed selector:' <<<"$passed_output"; then
  echo "Unexpected failed selector in passed diagnosis." >&2
  exit 1
fi
if grep -Fq 'Most suspicious:' <<<"$passed_output"; then
  echo "Unexpected suspicious files in passed diagnosis." >&2
  exit 1
fi

passed_summary="$("$runner" report "$passed_run" --summary)"
jq -e '
  .status == "SUCCESS" and
  .runResult == "passed" and
  .failureClass == "none" and
  .failedSelector == "" and
  .failureDomain == "none"
' <<<"$passed_summary" >/dev/null

export FAKE_RUN_RESULT=failed
export FAKE_RUNNER_STATUS=7
verify_run="$MOBTRACE_ARTIFACTS_ROOT/verify"
set +e
verify_output="$("$runner" verify login-logout --device test-device --artifacts-dir "$verify_run" 2>&1)"
verify_status=$?
set -e

[[ "$verify_status" -eq 7 ]]
grep -Fq 'FAILED Login and logout with run-scoped identity' <<<"$verify_output"
grep -Fq "Report: $verify_run/failure_report.md" <<<"$verify_output"
[[ "$(wc -l < "$runner_invocations")" -eq 1 ]]

export FAKE_RUNNER_STATUS=0
security_verify_run="$MOBTRACE_ARTIFACTS_ROOT/security-verify"
security_output="$(
  "$runner" verify security-sessions \
    --device test-device \
    --artifacts-dir "$security_verify_run"
)"
grep -Fq 'FAILED Login and logout with run-scoped identity' <<<"$security_output"
grep -Fq "$security_verify_run" <<<"$(tail -n 1 "$runner_invocations")"
[[ "$(wc -l < "$runner_invocations")" -eq 2 ]]

camera_verify_run="$MOBTRACE_ARTIFACTS_ROOT/camera-verify"
camera_output="$(
  "$runner" verify camera-launch \
    --device test-device \
    --artifacts-dir "$camera_verify_run"
)"
grep -Fq 'FAILED Login and logout with run-scoped identity' <<<"$camera_output"
grep -Fq "$camera_verify_run" <<<"$(tail -n 1 "$runner_invocations")"
[[ "$(wc -l < "$runner_invocations")" -eq 3 ]]

echo "MobTrace CLI contract tests passed."
