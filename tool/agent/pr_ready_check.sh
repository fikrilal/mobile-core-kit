#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  tool/agent/pr_ready_check.sh [--env <dev|staging|prod>] [--skip-tests] [--check-codegen] [--no-fix]

Description:
  Runs the default "PR-ready" local quality loop:
    1) dart run tool/fix.dart --apply   (unless --no-fix)
    2) dart run tool/verify.dart --env <env> [--skip-tests] [--check-codegen]

Examples:
  tool/agent/pr_ready_check.sh
  tool/agent/pr_ready_check.sh --env dev --check-codegen
  tool/agent/pr_ready_check.sh --env dev --skip-tests
EOF
}

env_name="dev"
skip_tests=0
check_codegen=0
run_fix=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --env requires a value." >&2
        usage
        exit 2
      fi
      env_name="$2"
      shift 2
      ;;
    --skip-tests)
      skip_tests=1
      shift
      ;;
    --check-codegen)
      check_codegen=1
      shift
      ;;
    --no-fix)
      run_fix=0
      shift
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

case "$env_name" in
  dev|staging|prod) ;;
  *)
    echo "ERROR: Invalid --env '$env_name'. Expected one of: dev, staging, prod." >&2
    exit 2
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../.." && pwd)"
fi
cd "$repo_root"

if ! command -v dart >/dev/null 2>&1; then
  echo "ERROR: dart command not found in PATH." >&2
  exit 1
fi
run_cmd=( dart run )

if [[ $run_fix -eq 1 ]]; then
  echo "==> Running safe auto-fix"
  "${run_cmd[@]}" tool/fix.dart --apply
fi

verify_args=( tool/verify.dart --env "$env_name" )
if [[ $skip_tests -eq 1 ]]; then
  verify_args+=( --skip-tests )
fi
if [[ $check_codegen -eq 1 ]]; then
  verify_args+=( --check-codegen )
fi

echo "==> Running canonical verification"
"${run_cmd[@]}" "${verify_args[@]}"

echo
echo "PR-ready checks passed."
