#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  tool/agent/mobile_evidence_check.sh --device <device-id> [--flavor <dev|staging|prod>] [--target <integration_test/..._test.dart>] [--artifacts-dir <path>] [--no-example-env-fallback] [--google-services-json <path>]

Description:
  Runs integration_test targets on a real/emulated device and writes runtime
  evidence artifacts (logs + summary) under _artifacts/mobile/.

Defaults:
  --flavor dev
  --artifacts-dir _artifacts/mobile/<timestamp>
  --target all integration_test/*_test.dart files (sorted)
  --example-env-fallback enabled for dev/staging

Examples:
  tool/agent/mobile_evidence_check.sh --device emulator-5554
  tool/agent/mobile_evidence_check.sh --device emulator-5554 --target integration_test/auth_happy_path_test.dart
  tool/agent/mobile_evidence_check.sh --device emulator-5554 --flavor dev --artifacts-dir _artifacts/mobile/manual-run
  tool/agent/mobile_evidence_check.sh --device emulator-5554 --google-services-json /secure/path/google-services.json
EOF
}

device_id=""
flavor="dev"
artifacts_dir=""
targets=()
allow_example_env_fallback=1
google_services_input_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --device requires a value." >&2
        usage
        exit 2
      fi
      device_id="$2"
      shift 2
      ;;
    --flavor)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --flavor requires a value." >&2
        usage
        exit 2
      fi
      flavor="$2"
      shift 2
      ;;
    --target)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --target requires a value." >&2
        usage
        exit 2
      fi
      targets+=( "$2" )
      shift 2
      ;;
    --artifacts-dir)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --artifacts-dir requires a value." >&2
        usage
        exit 2
      fi
      artifacts_dir="$2"
      shift 2
      ;;
    --no-example-env-fallback)
      allow_example_env_fallback=0
      shift
      ;;
    --google-services-json)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --google-services-json requires a value." >&2
        usage
        exit 2
      fi
      google_services_input_path="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument '$1'." >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$device_id" ]]; then
  echo "ERROR: --device is required." >&2
  usage
  exit 2
fi

case "$flavor" in
  dev|staging|prod) ;;
  *)
    echo "ERROR: Invalid --flavor '$flavor'. Expected one of: dev, staging, prod." >&2
    exit 2
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../.." && pwd)"
fi
cd "$repo_root"

if [[ "${#targets[@]}" -eq 0 ]]; then
  mapfile -t discovered_targets < <(find integration_test -type f -name '*_test.dart' | sort)
  if [[ "${#discovered_targets[@]}" -eq 0 ]]; then
    echo "ERROR: No integration_test targets found." >&2
    exit 1
  fi
  targets=( "${discovered_targets[@]}" )
fi

if [[ -z "$artifacts_dir" ]]; then
  timestamp="$(date '+%Y%m%d_%H%M%S')"
  artifacts_dir="_artifacts/mobile/$timestamp"
fi
mkdir -p "$artifacts_dir/logs"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter command not found in PATH." >&2
  exit 1
fi
run_cmd=( flutter )

if ! command -v dart >/dev/null 2>&1; then
  echo "ERROR: dart command not found in PATH." >&2
  exit 1
fi
dart_cmd=( dart run )

env_file=".env/$flavor.yaml"
env_example_file=".env/$flavor.example.yaml"
env_source="existing"
if [[ ! -s "$env_file" ]]; then
  if [[ "$allow_example_env_fallback" -eq 1 && "$flavor" != "prod" && -s "$env_example_file" ]]; then
    cp "$env_example_file" "$env_file"
    env_source="copied-from-example"
  else
    echo "ERROR: Missing or empty env file: $env_file" >&2
    if [[ -f "$env_example_file" ]]; then
      echo "Hint: copy $env_example_file -> $env_file or re-run with fallback enabled." >&2
    fi
    exit 1
  fi
fi

google_services_source="existing"
if [[ -n "$google_services_input_path" ]]; then
  if [[ ! -s "$google_services_input_path" ]]; then
    echo "ERROR: --google-services-json path is missing or empty: $google_services_input_path" >&2
    exit 1
  fi
  google_services_dest="android/app/google-services.json"
  if [[ "$google_services_input_path" != "$google_services_dest" ]]; then
    cp "$google_services_input_path" "$google_services_dest"
  fi
  google_services_source="copied-from-flag"
fi

metadata_file="$artifacts_dir/metadata.txt"
{
  echo "timestamp=$(date -Iseconds)"
  echo "device=$device_id"
  echo "flavor=$flavor"
  echo "env_file=$env_file"
  echo "env_source=$env_source"
  echo "google_services_source=$google_services_source"
  echo "repo=$repo_root"
  echo "targets=${targets[*]}"
} > "$metadata_file"

summary_file="$artifacts_dir/summary.md"
{
  echo "# Mobile Runtime Evidence Summary"
  echo
  echo "- Device: \`$device_id\`"
  echo "- Flavor: \`$flavor\`"
  echo "- Env file: \`$env_file\` (\`$env_source\`)"
  echo "- Google services source: \`$google_services_source\`"
  echo "- Timestamp: \`$(date -Iseconds)\`"
  echo "- Artifacts dir: \`$artifacts_dir\`"
  echo
  echo "## Preflight"
} > "$summary_file"

fail_count=0

preflight_log="$artifacts_dir/logs/preflight.log"
{
  echo "==> Generating build config for env=$flavor"
} | tee "$preflight_log"

set +e
"${dart_cmd[@]}" tool/gen_config.dart --env "$flavor" 2>&1 | tee -a "$preflight_log"
preflight_exit="${PIPESTATUS[0]}"
set -e

if [[ "$preflight_exit" -eq 0 ]]; then
  echo "- ✅ build config generated (\`tool/gen_config.dart --env $flavor\`)" >> "$summary_file"
else
  echo "- ❌ build config generation failed (exit=$preflight_exit)" >> "$summary_file"
  echo
  echo "Mobile evidence preflight failed. See: $summary_file"
  exit 1
fi

google_services_candidates=(
  "android/app/src/$flavor/debug/google-services.json"
  "android/app/src/debug/$flavor/google-services.json"
  "android/app/src/$flavor/google-services.json"
  "android/app/src/debug/google-services.json"
  "android/app/src/${flavor}Debug/google-services.json"
  "android/app/google-services.json"
)
google_services_file=""
for candidate in "${google_services_candidates[@]}"; do
  if [[ -s "$candidate" ]]; then
    google_services_file="$candidate"
    break
  fi
done

if [[ -n "$google_services_file" ]]; then
  echo "google_services_file=$google_services_file" >> "$metadata_file"
  echo "- ✅ google-services present (\`$google_services_file\`)" >> "$summary_file"
else
  echo "- ❌ google-services missing for flavor \`$flavor\`" >> "$summary_file"
  echo >> "$summary_file"
  echo "Expected one of:" >> "$summary_file"
  for candidate in "${google_services_candidates[@]}"; do
    echo "- \`$candidate\`" >> "$summary_file"
  done
  echo
  echo "ERROR: google-services.json not found for flavor '$flavor'." >&2
  echo "See setup guide: docs/engineering/firebase_setup.md" >&2
  echo "Mobile evidence preflight failed. See: $summary_file"
  exit 1
fi

echo >> "$summary_file"
echo "## Results" >> "$summary_file"

for target in "${targets[@]}"; do
  if [[ ! -f "$target" ]]; then
    echo "ERROR: Target not found: $target" >&2
    exit 1
  fi

  safe_name="${target//\//_}"
  log_file="$artifacts_dir/logs/${safe_name}.log"

  echo "==> Running $target on $device_id (flavor=$flavor)"

  set +e
  "${run_cmd[@]}" test -d "$device_id" --flavor "$flavor" "$target" 2>&1 | tee "$log_file"
  test_exit="${PIPESTATUS[0]}"
  set -e

  if [[ "$test_exit" -eq 0 ]]; then
    echo "- ✅ \`$target\`" >> "$summary_file"
  else
    echo "- ❌ \`$target\` (exit=$test_exit)" >> "$summary_file"
    fail_count=$((fail_count + 1))
  fi
done

{
  echo
  echo "## Signal Extracts"
  echo
  echo "### Startup Metrics"
  grep -h "Startup metrics" "$artifacts_dir"/logs/*.log 2>/dev/null || echo "_No startup metric lines found._"
  echo
  echo "### Trace IDs"
  grep -h "traceId" "$artifacts_dir"/logs/*.log 2>/dev/null || echo "_No traceId lines found._"
} >> "$summary_file"

if [[ "$fail_count" -ne 0 ]]; then
  echo
  echo "Mobile evidence run completed with failures. See: $summary_file"
  exit 1
fi

echo
echo "Mobile evidence run completed successfully. See: $summary_file"
