#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runner="$script_dir/mobile_evidence_check.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

make_fake_runner() {
  local path="$1"
  local lane_name="$2"
  cat > "$path" <<EOF
#!/usr/bin/env bash
set -euo pipefail
artifacts_dir=""
while [[ \$# -gt 0 ]]; do
  if [[ \$1 == --artifacts-dir ]]; then artifacts_dir="\$2"; shift 2; else shift; fi
done
echo "$lane_name" >> "$temp_dir/invocations"
if [[ -n "\$artifacts_dir" ]]; then
  mkdir -p "\$artifacts_dir"
  echo "# $lane_name" > "\$artifacts_dir/summary.md"
fi
exit "\${${lane_name^^}_FAKE_STATUS:-0}"
EOF
  chmod +x "$path"
}

make_fake_runner "$temp_dir/flutter" flutter
make_fake_runner "$temp_dir/maestro" maestro
export MOBILE_EVIDENCE_FLUTTER_RUNNER="$temp_dir/flutter"
export MOBILE_EVIDENCE_MAESTRO_RUNNER="$temp_dir/maestro"

set +e
"$runner" --lane maestro --device test-device --skip-build >/dev/null 2>&1
invalid_status=$?
set -e
[[ "$invalid_status" -eq 2 ]]

"$runner" --device test-device
[[ "$(cat "$temp_dir/invocations")" == "flutter" ]]

: > "$temp_dir/invocations"
"$runner" --lane maestro --device test-device
[[ "$(cat "$temp_dir/invocations")" == "maestro" ]]

: > "$temp_dir/invocations"
all_dir="$temp_dir/all-pass"
"$runner" --lane all --device test-device --artifacts-dir "$all_dir"
[[ "$(cat "$temp_dir/invocations")" == $'flutter\nmaestro' ]]
grep -Fq 'Aggregate result: `passed`' "$all_dir/summary.md"

: > "$temp_dir/invocations"
export FLUTTER_FAKE_STATUS=1
failure_dir="$temp_dir/all-failure"
set +e
"$runner" --lane all --device test-device --artifacts-dir "$failure_dir"
status=$?
set -e
[[ "$status" -eq 1 ]]
[[ "$(cat "$temp_dir/invocations")" == $'flutter\nmaestro' ]]
grep -Fq 'flutter_exit_status=1' "$failure_dir/status.env"
grep -Fq 'maestro_exit_status=0' "$failure_dir/status.env"

echo "Mobile evidence lane contract tests passed."
