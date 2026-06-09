#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
reporter="$script_dir/mobile_failure_report.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

changed_files_fixture="$temp_dir/changed-files.txt"
git_diff_fixture="$temp_dir/git-diff.patch"
: > "$changed_files_fixture"
: > "$git_diff_fixture"
export MOBTRACE_CHANGED_FILES_FILE="$changed_files_fixture"
export MOBTRACE_GIT_DIFF_FILE="$git_diff_fixture"

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

cat > "$changed_files_fixture" <<'EOF'
lib/features/auth/presentation/login_page.dart
.maestro/flows/auth/login_logout.yaml
EOF
cat > "$git_diff_fixture" <<'EOF'
diff --git a/lib/features/auth/presentation/login_page.dart b/lib/features/auth/presentation/login_page.dart
index 1111111..2222222 100644
--- a/lib/features/auth/presentation/login_page.dart
+++ b/lib/features/auth/presentation/login_page.dart
@@ -1 +1 @@
-const title = 'Login';
+const title = 'Sign in';
diff --git a/.maestro/flows/auth/login_logout.yaml b/.maestro/flows/auth/login_logout.yaml
index 3333333..4444444 100644
--- a/.maestro/flows/auth/login_logout.yaml
+++ b/.maestro/flows/auth/login_logout.yaml
@@ -1 +1 @@
-    id: old_login_button
+    id: auth_login_button
EOF
selector_diff_run="$(create_run selector-diff ERROR failed "Assertion is false: id: auth_login_button is visible")"
"$reporter" "$selector_diff_run" >/dev/null
jq -e '.suspiciousFiles[0] == ".maestro/flows/auth/login_logout.yaml"' \
  "$selector_diff_run/failure_report.json" >/dev/null

cat > "$changed_files_fixture" <<'EOF'
lib/features/auth/presentation/login_controller.dart
lib/features/auth/presentation/login_page.dart
EOF
cat > "$git_diff_fixture" <<'EOF'
diff --git a/lib/features/auth/presentation/login_controller.dart b/lib/features/auth/presentation/login_controller.dart
index 1111111..2222222 100644
--- a/lib/features/auth/presentation/login_controller.dart
+++ b/lib/features/auth/presentation/login_controller.dart
@@ -1 +1 @@
-const state = 'idle';
+const state = 'ready';
diff --git a/lib/features/auth/presentation/login_page.dart b/lib/features/auth/presentation/login_page.dart
index 3333333..4444444 100644
--- a/lib/features/auth/presentation/login_page.dart
+++ b/lib/features/auth/presentation/login_page.dart
@@ -1 +1 @@
-  key: const ValueKey('old_login_button'),
+  key: const ValueKey('auth_login_button'),
EOF
semantics_diff_run="$(create_run semantics-diff ERROR failed "Assertion is false: id: auth_login_button is visible")"
"$reporter" "$semantics_diff_run" >/dev/null
jq -e '.suspiciousFiles[0] == "lib/features/auth/presentation/login_page.dart"' \
  "$semantics_diff_run/failure_report.json" >/dev/null

cat > "$changed_files_fixture" <<'EOF'
tool/agent/maestro_evidence_check.sh
lib/features/auth/data/model/remote/login_request_model.g.dart
lib/features/auth/data/datasource/remote/auth_remote_datasource.dart
EOF
cat > "$git_diff_fixture" <<'EOF'
diff --git a/tool/agent/maestro_evidence_check.sh b/tool/agent/maestro_evidence_check.sh
index 1111111..2222222 100755
--- a/tool/agent/maestro_evidence_check.sh
+++ b/tool/agent/maestro_evidence_check.sh
@@ -1 +1 @@
-echo old
+echo new
diff --git a/lib/features/auth/data/model/remote/login_request_model.g.dart b/lib/features/auth/data/model/remote/login_request_model.g.dart
index 5555555..6666666 100644
--- a/lib/features/auth/data/model/remote/login_request_model.g.dart
+++ b/lib/features/auth/data/model/remote/login_request_model.g.dart
@@ -1 +1 @@
-Map<String, dynamic> toJson() => {'email': email};
+Map<String, dynamic> toJson() => {'username': email};
diff --git a/lib/features/auth/data/datasource/remote/auth_remote_datasource.dart b/lib/features/auth/data/datasource/remote/auth_remote_datasource.dart
index 3333333..4444444 100644
--- a/lib/features/auth/data/datasource/remote/auth_remote_datasource.dart
+++ b/lib/features/auth/data/datasource/remote/auth_remote_datasource.dart
@@ -1 +1 @@
-  AuthEndpoint.login,
+  '/v1/auth/password/login',
EOF
backend_diff_run="$(create_run backend-diff ERROR failed "Request failed")"
echo "HTTP 401" > "$backend_diff_run/maestro/runner.log"
"$reporter" "$backend_diff_run" >/dev/null
jq -e '.suspiciousFiles[0] == "lib/features/auth/data/datasource/remote/auth_remote_datasource.dart"' \
  "$backend_diff_run/failure_report.json" >/dev/null

cat > "$changed_files_fixture" <<'EOF'
lib/features/auth/presentation/login_page.dart
lib/navigation/app_redirect.dart
EOF
cat > "$git_diff_fixture" <<'EOF'
diff --git a/lib/features/auth/presentation/login_page.dart b/lib/features/auth/presentation/login_page.dart
index 1111111..2222222 100644
--- a/lib/features/auth/presentation/login_page.dart
+++ b/lib/features/auth/presentation/login_page.dart
@@ -1 +1 @@
-const title = 'Login';
+const title = 'Sign in';
diff --git a/lib/navigation/app_redirect.dart b/lib/navigation/app_redirect.dart
index 3333333..4444444 100644
--- a/lib/navigation/app_redirect.dart
+++ b/lib/navigation/app_redirect.dart
@@ -1 +1 @@
-  return AuthRoutes.signIn;
+  return AppRoutes.home;
EOF
navigation_diff_run="$(create_run navigation-diff ERROR failed "App did not navigate to expected screen")"
"$reporter" "$navigation_diff_run" >/dev/null
jq -e '.suspiciousFiles[0] == "lib/navigation/app_redirect.dart"' \
  "$navigation_diff_run/failure_report.json" >/dev/null

cat > "$changed_files_fixture" <<'EOF'
lib/features/auth/data/repository/auth_repository_impl.dart
tool/agent/auth_fixture_evidence_check.sh
EOF
cat > "$git_diff_fixture" <<'EOF'
diff --git a/lib/features/auth/data/repository/auth_repository_impl.dart b/lib/features/auth/data/repository/auth_repository_impl.dart
index 1111111..2222222 100644
--- a/lib/features/auth/data/repository/auth_repository_impl.dart
+++ b/lib/features/auth/data/repository/auth_repository_impl.dart
@@ -1 +1 @@
-const message = 'old';
+const message = 'new';
diff --git a/tool/agent/auth_fixture_evidence_check.sh b/tool/agent/auth_fixture_evidence_check.sh
index 3333333..4444444 100755
--- a/tool/agent/auth_fixture_evidence_check.sh
+++ b/tool/agent/auth_fixture_evidence_check.sh
@@ -1 +1 @@
-cleanup_identity
+revoke_fixture_sessions
EOF
fixture_diff_run="$(create_run fixture-diff ERROR failed "Cleanup failed")"
echo "Session revocation failed" > "$fixture_diff_run/maestro/runner.log"
"$reporter" "$fixture_diff_run" >/dev/null
jq -e '.suspiciousFiles[0] == "tool/agent/auth_fixture_evidence_check.sh"' \
  "$fixture_diff_run/failure_report.json" >/dev/null

echo "Mobile failure report contract tests passed."
