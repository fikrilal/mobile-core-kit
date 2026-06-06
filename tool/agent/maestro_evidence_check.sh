#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  tool/agent/maestro_evidence_check.sh --device <id> [options]

Options:
  --flavor <dev|staging|prod>  App flavor (default: dev).
  --flow <path>                Flow file or directory; repeatable.
  --include-tags <csv>         Run only flows with these tags.
  --exclude-tags <csv>         Exclude flows with these tags.
  --app-file <apk>             Use an existing APK instead of the default build output.
  --skip-build                 Do not build; requires --app-file.
  --artifacts-dir <path>       Evidence directory (default: timestamped under _artifacts/mobile).
  --google-services-json <path> Copy Firebase config before validation.
  --no-example-env-fallback    Require the flavor env file to already exist.
  --allow-prod                 Explicitly permit the prod flavor.
  -h, --help                   Show this help.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_value() {
  local option="$1"
  local count="$2"
  [[ "$count" -ge 2 ]] || { echo "ERROR: $option requires a value." >&2; usage; exit 2; }
}

resolve_command() {
  local override="$1"
  local name="$2"
  local fallback="${3:-}"
  if [[ -n "$override" ]]; then
    [[ -x "$override" ]] || fail "$name is not executable: $override"
    printf '%s\n' "$override"
  elif command -v "$name" >/dev/null 2>&1; then
    command -v "$name"
  elif [[ -n "$fallback" && -x "$fallback" ]]; then
    printf '%s\n' "$fallback"
  else
    fail "$name command not found."
  fi
}

device_id=""
flavor="dev"
include_tags=""
exclude_tags=""
app_file=""
artifacts_dir=""
google_services_input_path=""
skip_build=0
allow_prod=0
allow_example_env_fallback=1
flows=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) require_value "$1" "$#"; device_id="$2"; shift 2 ;;
    --flavor) require_value "$1" "$#"; flavor="$2"; shift 2 ;;
    --flow) require_value "$1" "$#"; flows+=( "$2" ); shift 2 ;;
    --include-tags) require_value "$1" "$#"; include_tags="$2"; shift 2 ;;
    --exclude-tags) require_value "$1" "$#"; exclude_tags="$2"; shift 2 ;;
    --app-file) require_value "$1" "$#"; app_file="$2"; shift 2 ;;
    --skip-build) skip_build=1; shift ;;
    --artifacts-dir) require_value "$1" "$#"; artifacts_dir="$2"; shift 2 ;;
    --google-services-json) require_value "$1" "$#"; google_services_input_path="$2"; shift 2 ;;
    --no-example-env-fallback) allow_example_env_fallback=0; shift ;;
    --allow-prod) allow_prod=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown argument '$1'." >&2; usage; exit 2 ;;
  esac
done

[[ -n "$device_id" ]] || { echo "ERROR: --device is required." >&2; usage; exit 2; }
case "$flavor" in
  dev|staging|prod) ;;
  *) echo "ERROR: Invalid --flavor '$flavor'. Expected one of: dev, staging, prod." >&2; exit 2 ;;
esac
if [[ "$flavor" == "prod" && "$allow_prod" -ne 1 ]]; then
  fail "prod execution requires --allow-prod."
fi
if [[ "$flavor" == "prod" ]]; then
  if [[ -n "$exclude_tags" ]]; then
    exclude_tags="$exclude_tags,destructive,requires_backend"
  else
    exclude_tags="destructive,requires_backend"
  fi
fi
if [[ "$skip_build" -eq 1 && -z "$app_file" ]]; then
  echo "ERROR: --skip-build requires --app-file." >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || repo_root="$(cd "$script_dir/../.." && pwd)"
cd "$repo_root"

if [[ -z "$artifacts_dir" ]]; then
  artifacts_dir="_artifacts/mobile/$(date '+%Y%m%d_%H%M%S')"
fi
maestro_dir="$artifacts_dir/maestro"
mkdir -p "$maestro_dir/artifacts"
runner_log="$maestro_dir/runner.log"
exec > >(tee -a "$runner_log") 2>&1

started_at="$(date -Iseconds)"
start_epoch="$(date +%s)"
summary_file="$artifacts_dir/summary.md"
metadata_file="$artifacts_dir/metadata.txt"
status_file="$artifacts_dir/status.env"
junit_file="$maestro_dir/junit.xml"
device_log="$maestro_dir/device.log"
log_session="maestro-${device_id//[^A-Za-z0-9._-]/-}-$$"
log_stream_started=0
run_result="failed"
exit_status=1

cleanup() {
  local original_exit=$?
  trap - EXIT INT TERM
  if [[ "$log_stream_started" -eq 1 ]]; then
    "$script_dir/flutter_log_stream.sh" stop --session "$log_session" --artifacts-dir "$maestro_dir" || true
    local stream_log="$maestro_dir/$log_session/stream.log"
    [[ -f "$stream_log" ]] && cp "$stream_log" "$device_log"
  fi

  local final_exit="$exit_status"
  [[ "$original_exit" -eq 0 ]] || final_exit="$original_exit"
  local ended_at end_epoch duration
  ended_at="$(date -Iseconds)"
  end_epoch="$(date +%s)"
  duration=$((end_epoch - start_epoch))
  {
    echo "result=$run_result"
    echo "exit_status=$final_exit"
    echo "started_at=$started_at"
    echo "ended_at=$ended_at"
    echo "duration_seconds=$duration"
  } > "$status_file"
  {
    echo
    echo "## Outcome"
    echo
    echo "- Result: \`$run_result\`"
    echo "- Exit status: \`$final_exit\`"
    echo "- Ended: \`$ended_at\`"
    echo "- Duration: \`${duration}s\`"
    echo "- JUnit: \`$junit_file\`"
    echo "- Device log: \`$device_log\`"
    echo "- Maestro artifacts: \`$maestro_dir/artifacts\`"
  } >> "$summary_file"
  exit "$final_exit"
}
trap cleanup EXIT INT TERM

entrypoint="lib/main_${flavor}.dart"
[[ -f "$entrypoint" ]] || fail "Entrypoint not found: $entrypoint"
if [[ "${#flows[@]}" -eq 0 ]]; then
  mapfile -t flows < <(find .maestro/flows -type f -name '*.yaml' | sort)
  [[ "${#flows[@]}" -gt 0 ]] || fail "No Maestro flows found under .maestro/flows."
fi
for flow in "${flows[@]}"; do
  [[ -e "$flow" ]] || fail "Selected flow not found: $flow"
done
[[ -s ".maestro/config.yaml" ]] || fail "Missing or empty Maestro config: .maestro/config.yaml"

maestro_bin="$(resolve_command "${MAESTRO_BIN:-}" maestro "$HOME/.maestro/bin/maestro")"
java_bin="$(resolve_command "${JAVA_BIN:-}" java)"
fvm_bin="$(resolve_command "${FVM_BIN:-}" fvm)"
adb_bin="$(resolve_command "${ADB_BIN:-}" adb "${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb")"
apkanalyzer_bin="$(resolve_command "${APKANALYZER_BIN:-}" apkanalyzer "${ANDROID_HOME:-$HOME/Android/Sdk}/cmdline-tools/latest/bin/apkanalyzer")"

pinned_maestro_version="$(tr -d '[:space:]' < "$script_dir/maestro_version.txt")"
installed_maestro_version="$($maestro_bin --version 2>&1 | tr -d '\r' | tail -n 1 | awk '{print $NF}')"
[[ "$installed_maestro_version" == "$pinned_maestro_version" ]] || fail "Maestro version mismatch: expected $pinned_maestro_version, found $installed_maestro_version."

java_version="$($java_bin -version 2>&1 | head -n 1)"
flutter_version="$($fvm_bin flutter --version 2>&1 | head -n 1)"
[[ -n "$java_version" ]] || fail "Unable to read Java version."
[[ -n "$flutter_version" ]] || fail "Unable to read FVM Flutter version."

if ! "$adb_bin" devices | awk 'NR > 1 && $2 == "device" {print $1}' | grep -Fxq "$device_id"; then
  fail "Device '$device_id' is not connected and ready."
fi

env_file=".env/$flavor.yaml"
env_example_file=".env/$flavor.example.yaml"
env_source="existing"
if [[ ! -s "$env_file" ]]; then
  if [[ "$allow_example_env_fallback" -eq 1 && "$flavor" != "prod" && -s "$env_example_file" ]]; then
    cp "$env_example_file" "$env_file"
    env_source="copied-from-example"
  else
    fail "Missing or empty env file: $env_file"
  fi
fi

if [[ -n "$google_services_input_path" ]]; then
  [[ -s "$google_services_input_path" ]] || fail "Firebase config is missing or empty: $google_services_input_path"
  cp "$google_services_input_path" android/app/google-services.json
fi

google_services_file=""
for candidate in \
  "android/app/src/$flavor/debug/google-services.json" \
  "android/app/src/debug/$flavor/google-services.json" \
  "android/app/src/$flavor/google-services.json" \
  "android/app/src/debug/google-services.json" \
  "android/app/src/${flavor}Debug/google-services.json" \
  "android/app/google-services.json"; do
  if [[ -s "$candidate" ]]; then google_services_file="$candidate"; break; fi
done
[[ -n "$google_services_file" ]] || fail "google-services.json not found for flavor '$flavor'. See docs/engineering/firebase_setup.md."

echo "==> Generating build config for env=$flavor"
"$fvm_bin" dart run tool/gen_config.dart --env "$flavor"

if [[ "$skip_build" -ne 1 && -z "$app_file" ]]; then
  echo "==> Building debug APK for flavor=$flavor"
  "$fvm_bin" flutter build apk --debug --flavor "$flavor" -t "$entrypoint" "--dart-define=ENV=$flavor"
  app_file="build/app/outputs/flutter-apk/app-${flavor}-debug.apk"
fi
[[ -s "$app_file" ]] || fail "APK is missing or empty: $app_file"

app_id="$($apkanalyzer_bin manifest application-id "$app_file" 2>/dev/null | tr -d '[:space:]')"
[[ -n "$app_id" ]] || fail "Unable to inspect application ID from APK: $app_file"
app_checksum="$(sha256sum "$app_file" | awk '{print $1}')"

echo "==> Installing $app_file"
"$adb_bin" -s "$device_id" install -r -t "$app_file"
if ! "$adb_bin" -s "$device_id" shell pm path "$app_id" | grep -q '^package:'; then
  fail "Installed package does not match APK application ID: $app_id"
fi

device_model="$($adb_bin -s "$device_id" shell getprop ro.product.model | tr -d '\r')"
android_api="$($adb_bin -s "$device_id" shell getprop ro.build.version.sdk | tr -d '\r')"
device_abi="$($adb_bin -s "$device_id" shell getprop ro.product.cpu.abi | tr -d '\r')"
git_commit="$(git rev-parse HEAD)"
git_dirty="false"
[[ -z "$(git status --porcelain)" ]] || git_dirty="true"

{
  echo "timestamp=$started_at"
  echo "git_commit=$git_commit"
  echo "git_dirty=$git_dirty"
  echo "device=$device_id"
  echo "device_model=$device_model"
  echo "android_api=$android_api"
  echo "device_abi=$device_abi"
  echo "flavor=$flavor"
  echo "entrypoint=$entrypoint"
  echo "app_id=$app_id"
  echo "app_file=$app_file"
  echo "app_sha256=$app_checksum"
  echo "env_file=$env_file"
  echo "env_source=$env_source"
  echo "google_services_file=$google_services_file"
  echo "maestro_version=$installed_maestro_version"
  echo "java_version=$java_version"
  echo "flutter_version=$flutter_version"
  echo "flows=${flows[*]}"
  echo "include_tags=$include_tags"
  echo "exclude_tags=$exclude_tags"
} > "$metadata_file"

{
  echo "# Maestro Runtime Evidence Summary"
  echo
  echo "- Git: \`$git_commit\` (dirty: \`$git_dirty\`)"
  echo "- Device: \`$device_id\` / \`$device_model\` / API \`$android_api\` / \`$device_abi\`"
  echo "- Flavor: \`$flavor\`"
  echo "- Entrypoint: \`$entrypoint\`"
  echo "- App ID: \`$app_id\`"
  echo "- APK: \`$app_file\`"
  echo "- APK SHA-256: \`$app_checksum\`"
  echo "- Flutter: \`$flutter_version\`"
  echo "- Java: \`$java_version\`"
  echo "- Maestro: \`$installed_maestro_version\`"
  echo "- Flows: \`${flows[*]}\`"
  echo "- Include tags: \`${include_tags:-none}\`"
  echo "- Exclude tags: \`${exclude_tags:-none}\`"
  echo "- Started: \`$started_at\`"
} > "$summary_file"

export PATH="$repo_root/.fvm/flutter_sdk/bin:$PATH"
echo "==> Starting device log capture"
"$script_dir/flutter_log_stream.sh" start --session "$log_session" --artifacts-dir "$maestro_dir" --mode logs --device "$device_id"
log_stream_started=1

maestro_args=(
  test
  --device "$device_id"
  --config .maestro/config.yaml
  -e "APP_ID=$app_id"
  --format junit
  --output "$junit_file"
  --test-output-dir "$maestro_dir/artifacts"
  --debug-output "$maestro_dir/artifacts"
  --flatten-debug-output
)
[[ -z "$include_tags" ]] || maestro_args+=( --include-tags "$include_tags" )
[[ -z "$exclude_tags" ]] || maestro_args+=( --exclude-tags "$exclude_tags" )
maestro_args+=( "${flows[@]}" )

printf '%q ' "$maestro_bin" "${maestro_args[@]}" > "$maestro_dir/command.txt"
printf '\n' >> "$maestro_dir/command.txt"
echo "==> Running Maestro"
set +e
MAESTRO_CLI_NO_ANALYTICS=1 MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED=true \
  "$maestro_bin" "${maestro_args[@]}" 2>&1 | tee "$maestro_dir/maestro.log"
exit_status="${PIPESTATUS[0]}"
set -e

{
  echo
  echo "## Flow Results"
  echo
  if [[ -s "$junit_file" ]]; then
    grep -o '<testcase[^>]*name="[^"]*"' "$junit_file" | sed -E 's/.*name="([^"]*)"/- `\1`/' || true
  else
    echo "_JUnit report was not generated._"
  fi
  echo
  echo "## Signal Extracts"
  echo
  grep -h -E 'Startup metrics|traceId' "$maestro_dir/$log_session/stream.log" 2>/dev/null || echo "_No startup metric or trace ID lines found._"
} >> "$summary_file"

if [[ "$exit_status" -eq 0 ]]; then
  run_result="passed"
  echo "Maestro evidence run completed successfully. See: $summary_file"
else
  run_result="failed"
  echo "Maestro evidence run failed (exit=$exit_status). See: $summary_file"
fi
exit "$exit_status"
