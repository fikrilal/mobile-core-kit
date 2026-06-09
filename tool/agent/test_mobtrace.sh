#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runner="$script_dir/../../mobtrace"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

fake_reporter="$temp_dir/fake_reporter"
cat > "$fake_reporter" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

run_dir="$1"
mkdir -p "$run_dir"

if [[ "${FAKE_RUN_RESULT:-failed}" == "passed" ]]; then
  cat > "$run_dir/failure_report.json" <<JSON
{
  "flow": "Login and logout with run-scoped identity",
  "status": "SUCCESS",
  "runResult": "passed",
  "failureClass": "none",
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

mkdir -p "$artifacts_dir/maestro"
echo '<testsuite><testcase name="fake"/></testsuite>' > "$artifacts_dir/maestro/junit.xml"
exit "${FAKE_RUNNER_STATUS:-0}"
EOF
chmod +x "$fake_runner"

export MOBTRACE_REPORTER="$fake_reporter"
export MOBTRACE_LOGIN_LOGOUT_RUNNER="$fake_runner"
export MOBTRACE_MAESTRO_RUNNER="$fake_runner"
export MOBTRACE_ARTIFACTS_ROOT="$temp_dir/artifacts"

failed_run="$MOBTRACE_ARTIFACTS_ROOT/failed"
mkdir -p "$failed_run/maestro"
echo '<testsuite><testcase name="failed"/></testsuite>' > "$failed_run/maestro/junit.xml"

failed_output="$("$runner" report latest)"
grep -Fq 'FAILED Login and logout with run-scoped identity' <<<"$failed_output"
grep -Fq 'Class: selector_mismatch' <<<"$failed_output"
grep -Fq 'Failed selector: auth_sign_in_pending_deep_link' <<<"$failed_output"
grep -Fq '1. .maestro/flows/auth/login_logout.yaml' <<<"$failed_output"
grep -Fq '2. lib/features/auth/presentation/login_page.dart' <<<"$failed_output"
grep -Fq 'Next action:' <<<"$failed_output"
grep -Fq "Report: $failed_run/failure_report.md" <<<"$failed_output"
grep -Fq "JSON: $failed_run/failure_report.json" <<<"$failed_output"

passed_run="$MOBTRACE_ARTIFACTS_ROOT/passed"
mkdir -p "$passed_run/maestro"
echo '<testsuite><testcase name="passed"/></testsuite>' > "$passed_run/maestro/junit.xml"
export FAKE_RUN_RESULT=passed

passed_output="$("$runner" report "$passed_run")"
grep -Fq 'PASSED Login and logout with run-scoped identity' <<<"$passed_output"
grep -Fq 'Class: none' <<<"$passed_output"
if grep -Fq 'Failed selector:' <<<"$passed_output"; then
  echo "Unexpected failed selector in passed diagnosis." >&2
  exit 1
fi
if grep -Fq 'Most suspicious:' <<<"$passed_output"; then
  echo "Unexpected suspicious files in passed diagnosis." >&2
  exit 1
fi

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

echo "MobTrace CLI contract tests passed."
