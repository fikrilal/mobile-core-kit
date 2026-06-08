#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  ./mobtrace doctor
  ./mobtrace report [latest|_artifacts/mobile/<run>]
  ./mobtrace verify login-logout --device <id> [evidence options]
  ./mobtrace verify --flow <path> --device <id> [evidence options]

Examples:
  ./mobtrace report latest
  ./mobtrace verify login-logout --device emulator-5554
  ./mobtrace verify --flow .maestro/flows/auth/login_logout.yaml --device emulator-5554

Evidence options are passed through to the underlying mobile evidence scripts.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 command not found."
}

require_value() {
  local option="$1"
  local count="$2"
  [[ "$count" -ge 2 ]] || { echo "ERROR: $option requires a value." >&2; usage; exit 2; }
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || repo_root="$(cd "$script_dir/../.." && pwd)"
cd "$repo_root"

reporter="$script_dir/mobile_failure_report.sh"
login_logout_runner="$script_dir/login_logout_evidence_check.sh"
maestro_runner="$script_dir/maestro_evidence_check.sh"

latest_run_dir() {
  [[ -d _artifacts/mobile ]] || return 0
  find _artifacts/mobile -path '*/maestro/junit.xml' -type f -printf '%T@ %h\n' 2>/dev/null |
    sort -nr |
    awk 'NR == 1 { sub(/\/maestro$/, "", $2); print $2 }'
}

run_report() {
  local run_dir="${1:-latest}"
  if [[ "$run_dir" == "latest" ]]; then
    run_dir="$(latest_run_dir)"
    [[ -n "$run_dir" ]] || fail "No mobile evidence run found under _artifacts/mobile."
  fi

  "$reporter" "$run_dir" >/dev/null
  echo "MobTrace report: $run_dir/failure_report.md"
  echo "MobTrace result: $run_dir/failure_report.json"
}

run_doctor() {
  require_command git
  require_command jq
  require_command rg
  require_command perl
  [[ -x "$reporter" ]] || fail "Reporter is not executable: $reporter"
  [[ -x "$login_logout_runner" ]] || fail "Login/logout runner is not executable: $login_logout_runner"
  [[ -x "$maestro_runner" ]] || fail "Maestro runner is not executable: $maestro_runner"
  echo "MobTrace doctor passed."
}

run_verify() {
  local target="${1:-}"
  if [[ "$target" == "-h" || "$target" == "--help" ]]; then
    usage
    exit 0
  fi
  [[ -n "$target" ]] || { usage; exit 2; }
  shift

  local artifacts_dir=""
  local flow=""
  local args=()

  case "$target" in
    login-logout)
      ;;
    --flow)
      require_value "$target" "$(( $# + 1 ))"
      flow="$1"
      shift
      ;;
    *)
      echo "ERROR: Unknown verify target '$target'." >&2
      usage
      exit 2
      ;;
  esac

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --artifacts-dir)
        require_value "$1" "$#"
        artifacts_dir="$2"
        args+=( "$1" "$2" )
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        args+=( "$1" )
        shift
        ;;
    esac
  done

  if [[ -z "$artifacts_dir" ]]; then
    case "$target" in
      login-logout) artifacts_dir="_artifacts/mobile/mobtrace-login-logout-$(date '+%Y%m%d_%H%M%S')" ;;
      --flow) artifacts_dir="_artifacts/mobile/mobtrace-flow-$(date '+%Y%m%d_%H%M%S')" ;;
    esac
    args+=( --artifacts-dir "$artifacts_dir" )
  fi

  set +e
  if [[ "$target" == "login-logout" ]]; then
    "$login_logout_runner" "${args[@]}"
  else
    "$maestro_runner" --flow "$flow" "${args[@]}"
  fi
  verify_status=$?
  set -e

  if [[ -s "$artifacts_dir/maestro/junit.xml" ]]; then
    run_report "$artifacts_dir"
  else
    echo "MobTrace report skipped: missing $artifacts_dir/maestro/junit.xml" >&2
  fi

  exit "$verify_status"
}

case "${1:-}" in
  doctor)
    shift
    [[ $# -eq 0 ]] || { usage; exit 2; }
    run_doctor
    ;;
  report|explain)
    shift
    [[ $# -le 1 ]] || { usage; exit 2; }
    run_report "${1:-latest}"
    ;;
  verify)
    shift
    run_verify "$@"
    ;;
  -h|--help|"")
    usage
    ;;
  *)
    echo "ERROR: Unknown command '$1'." >&2
    usage
    exit 2
    ;;
esac
