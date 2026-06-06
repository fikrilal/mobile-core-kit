#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runner="$script_dir/maestro_evidence_check.sh"
failures=0

expect_exit() {
  local expected="$1"
  local expected_text="$2"
  shift 2
  local output status
  set +e
  output="$("$runner" "$@" 2>&1)"
  status=$?
  set -e
  if [[ "$status" -ne "$expected" || "$output" != *"$expected_text"* ]]; then
    echo "FAIL: expected exit=$expected and text='$expected_text'" >&2
    echo "$output" >&2
    failures=$((failures + 1))
  fi
}

expect_exit 0 "Usage:" --help
expect_exit 2 "--device is required"
expect_exit 2 "Invalid --flavor" --device emulator-1 --flavor qa
expect_exit 2 "--skip-build requires --app-file" --device emulator-1 --skip-build
expect_exit 1 "prod execution requires --allow-prod" --device emulator-1 --flavor prod
expect_exit 1 "Selected flow not found" --device emulator-1 --flow .maestro/flows/missing.yaml

if [[ "$failures" -ne 0 ]]; then
  echo "$failures Maestro runner contract test(s) failed." >&2
  exit 1
fi

echo "Maestro runner contract tests passed."
