#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  ./mobtrace doctor
  ./mobtrace report [latest|_artifacts/mobile/<run>] [--summary]
  ./mobtrace show [latest|_artifacts/mobile/<run>]
  ./mobtrace verify login-logout --device <id> [evidence options]
  ./mobtrace verify --flow <path> --device <id> [evidence options]

Examples:
  ./mobtrace report latest
  ./mobtrace report latest --summary
  ./mobtrace show latest
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

reporter="${MOBTRACE_REPORTER:-$script_dir/mobile_failure_report.sh}"
login_logout_runner="${MOBTRACE_LOGIN_LOGOUT_RUNNER:-$script_dir/login_logout_evidence_check.sh}"
maestro_runner="${MOBTRACE_MAESTRO_RUNNER:-$script_dir/maestro_evidence_check.sh}"
artifacts_root="${MOBTRACE_ARTIFACTS_ROOT:-_artifacts/mobile}"
signatures_file="${MOBTRACE_SIGNATURES_FILE:-$script_dir/mobtrace_signatures.json}"

latest_run_dir() {
  [[ -d "$artifacts_root" ]] || return 0
  find "$artifacts_root" -path '*/maestro/junit.xml' -type f -printf '%T@ %h\n' 2>/dev/null |
    sort -nr |
    awk 'NR == 1 { sub(/\/maestro$/, "", $2); print $2 }'
}

resolve_run_dir() {
  local run_dir="${1:-latest}"
  if [[ "$run_dir" == "latest" ]]; then
    run_dir="$(latest_run_dir)"
    [[ -n "$run_dir" ]] || fail "No mobile evidence run found under $artifacts_root."
  fi
  [[ -d "$run_dir" ]] || fail "Evidence directory not found: $run_dir"
  printf '%s\n' "$run_dir"
}

report_is_stale() {
  local run_dir="$1"
  local report_md="$run_dir/failure_report.md"
  local report_json="$run_dir/failure_report.json"
  local changed_file

  [[ -s "$report_md" && -s "$report_json" ]] || return 0
  [[ "$reporter" -nt "$report_md" ]] && return 0
  if [[ -e "$signatures_file" && "$signatures_file" -nt "$report_md" ]]; then
    return 0
  fi
  if find "$run_dir" -type f \
    ! -name 'failure_report.md' \
    ! -name 'failure_report.json' \
    -newer "$report_md" -print -quit 2>/dev/null | grep -q .; then
    return 0
  fi

  if [[ -n "${MOBTRACE_CHANGED_FILES_FILE:-}" ]]; then
    while IFS= read -r changed_file; do
      [[ -e "$changed_file" && "$changed_file" -nt "$report_md" ]] && return 0
    done < "$MOBTRACE_CHANGED_FILES_FILE"
  else
    while IFS= read -r changed_file; do
      [[ -e "$changed_file" && "$changed_file" -nt "$report_md" ]] && return 0
    done < <(
      {
        git diff --name-only
        git ls-files --others --exclude-standard
      } | awk '!seen[$0]++'
    )
  fi

  return 1
}

print_diagnosis() {
  local run_dir="$1"
  local result_json="$run_dir/failure_report.json"
  [[ -s "$result_json" ]] || fail "Missing MobTrace result: $result_json"

  local flow
  local result
  local failure_class
  local failure_domain
  local failed_selector
  local suggested_action

  flow="$(jq -r '.flow // "unknown"' "$result_json")"
  result="$(jq -r '
    if .runResult == "passed" then "PASSED"
    elif .runResult == "failed" then "FAILED"
    else (.status // "UNKNOWN" | ascii_upcase)
    end
  ' "$result_json")"
  failure_class="$(jq -r '.failureClass // "unknown"' "$result_json")"
  failure_domain="$(jq -r '.failureDomain // "unknown"' "$result_json")"
  failed_selector="$(jq -r '.failedCommand.selector // ""' "$result_json")"
  suggested_action="$(jq -r '.suggestedAction // "Inspect the full MobTrace report."' "$result_json")"

  echo "$result $flow"
  echo "Class: $failure_class"
  echo "Domain: $failure_domain"
  if [[ -n "$failed_selector" ]]; then
    echo "Failed selector: $failed_selector"
  fi

  if jq -e '.suspiciousFiles | length > 0' "$result_json" >/dev/null; then
    echo
    echo "Most suspicious:"
    jq -r '.suspiciousFiles[]' "$result_json" | nl -w1 -s'. '
  fi

  echo
  echo "Next action:"
  echo "$suggested_action"
  echo
  echo "Report: $run_dir/failure_report.md"
  echo "JSON: $result_json"
}

print_summary() {
  local run_dir="$1"
  local result_json="$run_dir/failure_report.json"
  [[ -s "$result_json" ]] || fail "Missing MobTrace result: $result_json"

  jq -c \
    --arg report "$run_dir/failure_report.md" \
    --arg json "$result_json" \
    '{
      status: (.status // "unknown"),
      runResult: (.runResult // "unknown"),
      failureClass: (.failureClass // "unknown"),
      failedSelector: (.failedCommand.selector // ""),
      failureDomain: (.failureDomain // "unknown"),
      report: $report,
      json: $json,
      suggestedAction: (.suggestedAction // "Inspect the full MobTrace report.")
    }' "$result_json"
}

run_report() {
  local run_dir
  local output_mode="${2:-diagnosis}"
  run_dir="$(resolve_run_dir "${1:-latest}")"

  "$reporter" "$run_dir" >/dev/null
  case "$output_mode" in
    diagnosis) print_diagnosis "$run_dir" ;;
    summary) print_summary "$run_dir" ;;
    *) fail "Unsupported report output mode: $output_mode" ;;
  esac
}

run_show() {
  local run_dir
  run_dir="$(resolve_run_dir "${1:-latest}")"

  if report_is_stale "$run_dir"; then
    "$reporter" "$run_dir" >/dev/null
  fi

  [[ -s "$run_dir/failure_report.md" ]] ||
    fail "Missing MobTrace report: $run_dir/failure_report.md"
  cat "$run_dir/failure_report.md"
}

run_show_command() {
  case "$#" in
    0) run_show latest ;;
    1)
      if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        usage
      elif [[ "$1" == -* ]]; then
        echo "ERROR: Unknown show option '$1'." >&2
        usage
        exit 2
      else
        run_show "$1"
      fi
      ;;
    *)
      echo "ERROR: Show accepts at most one evidence directory." >&2
      usage
      exit 2
      ;;
  esac
}

run_report_command() {
  local run_dir="latest"
  local run_dir_set=0
  local output_mode="diagnosis"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --summary)
        output_mode="summary"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        echo "ERROR: Unknown report option '$1'." >&2
        usage
        exit 2
        ;;
      *)
        if [[ "$run_dir_set" -eq 1 ]]; then
          echo "ERROR: Report accepts at most one evidence directory." >&2
          usage
          exit 2
        fi
        run_dir="$1"
        run_dir_set=1
        shift
        ;;
    esac
  done

  run_report "$run_dir" "$output_mode"
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
      login-logout) artifacts_dir="$artifacts_root/mobtrace-login-logout-$(date '+%Y%m%d_%H%M%S')" ;;
      --flow) artifacts_dir="$artifacts_root/mobtrace-flow-$(date '+%Y%m%d_%H%M%S')" ;;
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
    set +e
    run_report "$artifacts_dir"
    report_status=$?
    set -e
    if [[ "$report_status" -ne 0 ]]; then
      echo "MobTrace report generation failed with exit status $report_status." >&2
    fi
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
    run_report_command "$@"
    ;;
  show)
    shift
    run_show_command "$@"
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
