#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  tool/agent/mobile_evidence_check.sh --device <id> [options]

Common options:
  --lane <flutter|maestro|all>  Evidence lane (default: flutter).
  --flavor <dev|staging|prod>   App flavor (default: dev).
  --artifacts-dir <path>        Evidence directory.
  --no-example-env-fallback     Require the flavor env file to exist.
  --google-services-json <path> Copy Firebase config before validation.

Flutter lane:
  --target <integration_test>   Integration target; repeatable.

Maestro lane:
  --flow <path>                 Flow file or directory; repeatable.
  --include-tags <csv>          Run only flows with these tags.
  --exclude-tags <csv>          Exclude flows with these tags.
  --app-file <apk>              Use an existing APK.
  --skip-build                  Do not build; requires --app-file.
  --allow-prod                  Explicitly permit Maestro against prod.
EOF
}

require_value() {
  local option="$1"
  local count="$2"
  [[ "$count" -ge 2 ]] || { echo "ERROR: $option requires a value." >&2; usage; exit 2; }
}

lane="flutter"
device_id=""
flavor="dev"
artifacts_dir=""
google_services_json=""
no_example_env_fallback=0
targets=()
flows=()
include_tags=""
exclude_tags=""
app_file=""
skip_build=0
allow_prod=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lane) require_value "$1" "$#"; lane="$2"; shift 2 ;;
    --device) require_value "$1" "$#"; device_id="$2"; shift 2 ;;
    --flavor) require_value "$1" "$#"; flavor="$2"; shift 2 ;;
    --artifacts-dir) require_value "$1" "$#"; artifacts_dir="$2"; shift 2 ;;
    --google-services-json) require_value "$1" "$#"; google_services_json="$2"; shift 2 ;;
    --no-example-env-fallback) no_example_env_fallback=1; shift ;;
    --target) require_value "$1" "$#"; targets+=( "$2" ); shift 2 ;;
    --flow) require_value "$1" "$#"; flows+=( "$2" ); shift 2 ;;
    --include-tags) require_value "$1" "$#"; include_tags="$2"; shift 2 ;;
    --exclude-tags) require_value "$1" "$#"; exclude_tags="$2"; shift 2 ;;
    --app-file) require_value "$1" "$#"; app_file="$2"; shift 2 ;;
    --skip-build) skip_build=1; shift ;;
    --allow-prod) allow_prod=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown argument '$1'." >&2; usage; exit 2 ;;
  esac
done

[[ -n "$device_id" ]] || { echo "ERROR: --device is required." >&2; usage; exit 2; }
case "$lane" in
  flutter|maestro|all) ;;
  *) echo "ERROR: Invalid --lane '$lane'. Expected one of: flutter, maestro, all." >&2; exit 2 ;;
esac
case "$flavor" in
  dev|staging|prod) ;;
  *) echo "ERROR: Invalid --flavor '$flavor'. Expected one of: dev, staging, prod." >&2; exit 2 ;;
esac

if [[ "$lane" == "flutter" && ( "${#flows[@]}" -gt 0 || -n "$include_tags" || -n "$exclude_tags" || -n "$app_file" || "$skip_build" -eq 1 || "$allow_prod" -eq 1 ) ]]; then
  echo "ERROR: Maestro options require --lane maestro or --lane all." >&2
  exit 2
fi
if [[ "$lane" == "maestro" && "${#targets[@]}" -gt 0 ]]; then
  echo "ERROR: --target requires --lane flutter or --lane all." >&2
  exit 2
fi
if [[ "$lane" != "flutter" && "$skip_build" -eq 1 && -z "$app_file" ]]; then
  echo "ERROR: --skip-build requires --app-file." >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || repo_root="$(cd "$script_dir/../.." && pwd)"
cd "$repo_root"

flutter_runner="${MOBILE_EVIDENCE_FLUTTER_RUNNER:-$script_dir/flutter_evidence_check.sh}"
maestro_runner="${MOBILE_EVIDENCE_MAESTRO_RUNNER:-$script_dir/maestro_evidence_check.sh}"
[[ -x "$flutter_runner" ]] || { echo "ERROR: Flutter evidence runner is not executable: $flutter_runner" >&2; exit 1; }
[[ -x "$maestro_runner" ]] || { echo "ERROR: Maestro evidence runner is not executable: $maestro_runner" >&2; exit 1; }

common_args=( --device "$device_id" --flavor "$flavor" )
[[ "$no_example_env_fallback" -eq 0 ]] || common_args+=( --no-example-env-fallback )
[[ -z "$google_services_json" ]] || common_args+=( --google-services-json "$google_services_json" )

flutter_args=( "${common_args[@]}" )
for target in "${targets[@]}"; do flutter_args+=( --target "$target" ); done

maestro_args=( "${common_args[@]}" )
for flow in "${flows[@]}"; do maestro_args+=( --flow "$flow" ); done
[[ -z "$include_tags" ]] || maestro_args+=( --include-tags "$include_tags" )
[[ -z "$exclude_tags" ]] || maestro_args+=( --exclude-tags "$exclude_tags" )
[[ -z "$app_file" ]] || maestro_args+=( --app-file "$app_file" )
[[ "$skip_build" -eq 0 ]] || maestro_args+=( --skip-build )
[[ "$allow_prod" -eq 0 ]] || maestro_args+=( --allow-prod )

case "$lane" in
  flutter)
    [[ -z "$artifacts_dir" ]] || flutter_args+=( --artifacts-dir "$artifacts_dir" )
    exec "$flutter_runner" "${flutter_args[@]}"
    ;;
  maestro)
    [[ -z "$artifacts_dir" ]] || maestro_args+=( --artifacts-dir "$artifacts_dir" )
    exec "$maestro_runner" "${maestro_args[@]}"
    ;;
esac

if [[ -z "$artifacts_dir" ]]; then
  artifacts_dir="_artifacts/mobile/$(date '+%Y%m%d_%H%M%S')"
fi
mkdir -p "$artifacts_dir"
flutter_dir="$artifacts_dir/flutter"
maestro_dir="$artifacts_dir/maestro"
flutter_args+=( --artifacts-dir "$flutter_dir" )
maestro_args+=( --artifacts-dir "$maestro_dir" )
if [[ -n "$app_file" ]]; then
  [[ -s "$app_file" ]] || { echo "ERROR: APK is missing or empty: $app_file" >&2; exit 1; }
  maestro_app_snapshot="$artifacts_dir/maestro-input.apk"
  cp "$app_file" "$maestro_app_snapshot"
  for index in "${!maestro_args[@]}"; do
    if [[ "${maestro_args[$index]}" == "$app_file" ]]; then
      maestro_args[$index]="$maestro_app_snapshot"
    fi
  done
fi

started_at="$(date -Iseconds)"
start_epoch="$(date +%s)"
echo "==> Running Flutter evidence lane"
set +e
"$flutter_runner" "${flutter_args[@]}" 2>&1 | tee "$artifacts_dir/flutter.log"
flutter_status="${PIPESTATUS[0]}"
echo "==> Running Maestro evidence lane"
"$maestro_runner" "${maestro_args[@]}" 2>&1 | tee "$artifacts_dir/maestro.log"
maestro_status="${PIPESTATUS[0]}"
set -e

aggregate_status=0
[[ "$flutter_status" -eq 0 && "$maestro_status" -eq 0 ]] || aggregate_status=1
ended_at="$(date -Iseconds)"
duration_seconds=$(( $(date +%s) - start_epoch ))
result="passed"
[[ "$aggregate_status" -eq 0 ]] || result="failed"

{
  echo "# Mobile Runtime Evidence Summary"
  echo
  echo "- Lane: \`all\`"
  echo "- Device: \`$device_id\`"
  echo "- Flavor: \`$flavor\`"
  echo "- Started: \`$started_at\`"
  echo "- Ended: \`$ended_at\`"
  echo "- Duration: \`${duration_seconds}s\`"
  echo "- Aggregate result: \`$result\`"
  echo
  echo "## Lane Results"
  echo
  echo "- Flutter: \`$([[ "$flutter_status" -eq 0 ]] && echo passed || echo failed)\` (exit \`$flutter_status\`)"
  echo "  Summary: \`$flutter_dir/summary.md\`"
  echo "- Maestro: \`$([[ "$maestro_status" -eq 0 ]] && echo passed || echo failed)\` (exit \`$maestro_status\`)"
  echo "  Summary: \`$maestro_dir/summary.md\`"
} > "$artifacts_dir/summary.md"

{
  echo "result=$result"
  echo "exit_status=$aggregate_status"
  echo "flutter_exit_status=$flutter_status"
  echo "maestro_exit_status=$maestro_status"
  echo "started_at=$started_at"
  echo "ended_at=$ended_at"
  echo "duration_seconds=$duration_seconds"
} > "$artifacts_dir/status.env"

echo "Mobile evidence lanes completed with result=$result. See: $artifacts_dir/summary.md"
exit "$aggregate_status"
