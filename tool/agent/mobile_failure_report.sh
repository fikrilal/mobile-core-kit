#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  tool/agent/mobile_failure_report.sh _artifacts/mobile/<run>

Generates:
  <run>/failure_report.md
  <run>/failure_report.json

This is a local MobTrace prototype. It does not run mobile tests; it explains
an existing evidence directory using Maestro artifacts, logs, and git diff.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 command not found."
}

xml_unescape() {
  sed \
    -e 's/&quot;/"/g' \
    -e "s/&apos;/'/g" \
    -e 's/&lt;/</g' \
    -e 's/&gt;/>/g' \
    -e 's/&amp;/\&/g'
}

first_match() {
  local file="$1"
  local pattern="$2"
  if [[ -s "$file" ]]; then
    rg -m 1 -o "$pattern" "$file" 2>/dev/null || true
  fi
}

diff_files_matching() {
  local diff_file="$1"
  local path_pattern="$2"
  local line_pattern="$3"

  awk \
    -v path_pattern="$path_pattern" \
    -v line_pattern="$line_pattern" '
      function emit() {
        if (file != "" && path_matches && line_matches) print file
      }
      /^diff --git a\// {
        emit()
        file = $4
        sub(/^b\//, "", file)
        path_matches = file ~ path_pattern
        if (file ~ /(\.g|\.freezed)\.dart$/) path_matches = 0
        line_matches = 0
        next
      }
      path_matches && /^[+-][^+-]/ {
        line = tolower(substr($0, 2))
        if (line ~ line_pattern) line_matches = 1
      }
      END {
        emit()
      }
    ' "$diff_file"
}

resolve_flow_file() {
  local metadata_file="$1"
  local expected_flow_name="$2"
  local candidate
  local candidate_name

  if [[ -n "${MOBTRACE_FLOW_FILE:-}" ]]; then
    [[ -f "$MOBTRACE_FLOW_FILE" ]] && printf '%s\n' "$MOBTRACE_FLOW_FILE"
    return 0
  fi

  [[ -s "$metadata_file" ]] || return 0
  while IFS= read -r candidate; do
    [[ -f "$candidate" ]] || continue
    candidate_name="$(
      sed -n -E 's/^name:[[:space:]]*(.*)$/\1/p' "$candidate" | head -n 1
    )"
    if [[ "$candidate_name" == "$expected_flow_name" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done < <(
    awk '
      /^flows=/ {
        sub(/^flows=/, "")
        count = split($0, paths, /[[:space:]]+/)
        for (i = 1; i <= count; i++) {
          if (paths[i] != "") print paths[i]
        }
      }
    ' "$metadata_file"
  )
  return 0
}

parse_flow_metadata() {
  local flow_file="$1"
  local area_file="$2"
  local owns_file="$3"

  : > "$area_file"
  : > "$owns_file"
  [[ -s "$flow_file" ]] || return 0

  awk -v area_file="$area_file" -v owns_file="$owns_file" '
    BEGIN {
      in_mobtrace = 0
      in_owns = 0
    }
    /^#[[:space:]]*mobtrace:[[:space:]]*$/ {
      in_mobtrace = 1
      next
    }
    in_mobtrace && !/^#/ {
      exit
    }
    in_mobtrace {
      line = $0
      sub(/^#[[:space:]]*/, "", line)
      sub(/^[[:space:]]+/, "", line)
      if (line ~ /^area:[[:space:]]*/) {
        sub(/^area:[[:space:]]*/, "", line)
        print line > area_file
        next
      }
      if (line ~ /^owns:[[:space:]]*$/) {
        in_owns = 1
        next
      }
      if (in_owns && line ~ /^-[[:space:]]+/) {
        sub(/^-[[:space:]]+/, "", line)
        if (line != "") print line > owns_file
        next
      }
      if (line !~ /^[[:space:]]*$/) in_owns = 0
    }
  ' "$flow_file"
}

metadata_owned_files() {
  local changed_files_file="$1"
  local owns_file="$2"

  [[ -s "$owns_file" ]] || return 0
  awk '
    NR == FNR {
      owns[++count] = $0
      next
    }
    {
      for (i = 1; i <= count; i++) {
        if (index($0, owns[i]) == 1) {
          print
          next
        }
      }
    }
  ' "$owns_file" "$changed_files_file"
}

match_failure_signature() {
  local signatures_file="$1"
  local failure_class="$2"
  local failure_message="$3"
  local failed_command="$4"
  local failed_selector="$5"
  local hierarchy_file="$6"
  local logs_file="$7"
  local changed_files_file="$8"

  jq -c \
    --arg failureClass "$failure_class" \
    --arg failure "$failure_message" \
    --arg failedCommand "$failed_command" \
    --arg failedSelector "$failed_selector" \
    --rawfile hierarchy "$hierarchy_file" \
    --rawfile logs "$logs_file" \
    --rawfile changedFiles "$changed_files_file" \
    '
      def regex_matches($value; $pattern):
        ($pattern == null) or ($value | test($pattern; "im"));

      [
        .signatures[] |
        . as $signature |
        ($signature.match // {}) as $match |
        select(
          (($match.failureClass // null) == null or $match.failureClass == $failureClass) and
          regex_matches($failure; $match.failureRegex // null) and
          regex_matches($failedCommand; $match.failedCommandRegex // null) and
          regex_matches($hierarchy; $match.hierarchyRegex // null) and
          regex_matches($logs; $match.logsRegex // null) and
          regex_matches($changedFiles; $match.changedFilesRegex // null) and
          (
            (($match.selectorMissingFromHierarchy // false) | not) or
            (
              ($failedSelector | length) > 0 and
              (($hierarchy | ascii_downcase | contains($failedSelector | ascii_downcase)) | not)
            )
          )
        ) |
        {
          id: $signature.id,
          description: $signature.description,
          action: $signature.action
        }
      ] | first // null
    ' "$signatures_file"
}

require_command jq
require_command rg
require_command git

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

[[ $# -eq 1 ]] || { usage; exit 2; }

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
signatures_file="${MOBTRACE_SIGNATURES_FILE:-$script_dir/mobtrace_signatures.json}"
[[ -s "$signatures_file" ]] || fail "Missing MobTrace signatures: $signatures_file"
jq -e '
  .version == 1 and
  (.signatures | type == "array") and
  (
    [.signatures[].id] as $ids |
    ($ids | length) == ($ids | unique | length)
  ) and
  all(
    .signatures[];
    (.id | type == "string" and length > 0) and
    (.description | type == "string" and length > 0) and
    (.action | type == "string" and length > 0) and
    (.match | type == "object") and
    (
      .match |
      keys - [
        "changedFilesRegex",
        "failedCommandRegex",
        "failureClass",
        "failureRegex",
        "hierarchyRegex",
        "logsRegex",
        "selectorMissingFromHierarchy"
      ] |
      length == 0
    )
  )
' "$signatures_file" >/dev/null ||
  fail "Invalid MobTrace signatures file: $signatures_file"

run_dir="${1%/}"
[[ -d "$run_dir" ]] || fail "Evidence directory not found: $run_dir"

junit_file="$run_dir/maestro/junit.xml"
status_file="$run_dir/status.env"
metadata_file="$run_dir/metadata.txt"
maestro_log="$run_dir/maestro/maestro.log"
device_log="$run_dir/maestro/device.log"
runner_log="$run_dir/maestro/runner.log"
report_md="$run_dir/failure_report.md"
report_json="$run_dir/failure_report.json"

[[ -s "$junit_file" ]] || fail "Missing JUnit report: $junit_file"

commands_file="$(
  find "$run_dir/maestro/artifacts" -maxdepth 1 -type f -name 'commands-*.json' \
    2>/dev/null | sort | head -n 1
)"

flow_name="$(
  first_match "$junit_file" 'testcase[^>]*name="[^"]*"' |
    sed -E 's/.*name="([^"]*)"/\1/' |
    xml_unescape
)"
flow_name="${flow_name:-unknown}"

junit_status="$(
  first_match "$junit_file" 'testcase[^>]*status="[^"]*"' |
    sed -E 's/.*status="([^"]*)"/\1/' |
    xml_unescape
)"
junit_status="${junit_status:-unknown}"

failure_message="$(
  perl -0777 -ne 'print $1 if /<failure>(.*?)<\/failure>/s' "$junit_file" |
    sed -E 's/[[:space:]]+/ /g' |
    xml_unescape
)"

run_result="unknown"
if [[ -s "$status_file" ]]; then
  run_result="$(
    awk -F= '$1 == "result" {print $2; exit}' "$status_file"
  )"
fi

failed_command_json='{}'
failed_command_type=""
failed_selector=""
failed_command_message=""
hierarchy_text_file="$(mktemp)"
changed_files_file="$(mktemp)"
diff_file="$(mktemp)"
flow_area_file="$(mktemp)"
flow_owns_file="$(mktemp)"
trap 'rm -f "$hierarchy_text_file" "$changed_files_file" "$diff_file" "$flow_area_file" "$flow_owns_file"' EXIT

if [[ -n "$commands_file" && -s "$commands_file" ]]; then
  failed_command_json="$(
    jq -c '
      [.[]? | objects | select(.metadata.status? == "FAILED")] | first // {}
    ' "$commands_file"
  )"
  failed_command_type="$(
    jq -r '(.command // {}) | keys[0] // ""' <<<"$failed_command_json"
  )"
  failed_command_message="$(
    jq -r '
      .metadata.error.message //
      .metadata.error.localizedMessage //
      .metadata.error.debugMessage //
      ""
    ' <<<"$failed_command_json"
  )"
  failed_selector="$(
    jq -r '
      [
        .. | objects | .selector? | objects |
        (.textRegex // .idRegex // .text // .id // empty)
      ] + [
        .. | objects | .visible? | objects |
        (.textRegex // .idRegex // .text // .id // empty)
      ] | first // ""
    ' <<<"$failed_command_json"
  )"
  jq -r '
    [
      .. | objects | .attributes? | objects |
      (.accessibilityText?, .text?, .hintText?, .contentDescription?)
    ]
    | map(select(. != null and . != ""))
    | unique
    | .[]
  ' "$commands_file" > "$hierarchy_text_file"
else
  : > "$hierarchy_text_file"
fi

screenshots="$(
  find "$run_dir/maestro/artifacts" -type f \
    \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) \
    2>/dev/null | sort
)"
failure_screenshot="$(
  printf '%s\n' "$screenshots" | rg 'screenshot-|❌|failed|failure' -m 1 || true
)"
if [[ -z "$failure_screenshot" ]]; then
  failure_screenshot="$(printf '%s\n' "$screenshots" | head -n 1)"
fi

combined_logs_file="$(mktemp)"
trap 'rm -f "$hierarchy_text_file" "$changed_files_file" "$diff_file" "$flow_area_file" "$flow_owns_file" "$combined_logs_file"' EXIT
for log_file in "$runner_log" "$maestro_log" "$device_log"; do
  [[ -s "$log_file" ]] && cat "$log_file" >> "$combined_logs_file"
done

http_signal="$(
  rg -i -m 1 \
    'HTTP[ /][0-9]{3}|status[=:][[:space:]]*[0-9]{3}|\b(400|401|403|422|500)\b|VALIDATION_FAILED|UNAUTHORIZED|Body cannot be empty' \
    "$combined_logs_file" 2>/dev/null || true
)"

cleanup_signal="$(
  rg -i -m 1 'Fixture cleanup.*(failed|error)|cleanup .*failed|Session revocation failed|Active sessions remain' \
    "$combined_logs_file" 2>/dev/null || true
)"

device_signal="$(
  rg -i -m 1 'device .*not connected|device offline|no devices|Device .* is not connected' \
    "$combined_logs_file" 2>/dev/null || true
)"

if [[ -n "${MOBTRACE_CHANGED_FILES_FILE:-}" ]]; then
  cp "$MOBTRACE_CHANGED_FILES_FILE" "$changed_files_file"
else
  {
    git diff --name-only
    git ls-files --others --exclude-standard
  } | awk '!seen[$0]++' > "$changed_files_file"
fi

if [[ -n "${MOBTRACE_GIT_DIFF_FILE:-}" ]]; then
  cp "$MOBTRACE_GIT_DIFF_FILE" "$diff_file"
else
  git diff --no-ext-diff --unified=80 > "$diff_file"
fi

flow_file="$(resolve_flow_file "$metadata_file" "$flow_name")"
parse_flow_metadata "$flow_file" "$flow_area_file" "$flow_owns_file"
flow_area="$(head -n 1 "$flow_area_file")"

failure_class="unknown"
failure_domain="unknown"
suggested_action="Inspect the failed command, final screenshot, hierarchy text, and changed files."

if [[ "$junit_status" == "SUCCESS" || "$run_result" == "passed" ]]; then
  failure_class="none"
  failure_domain="none"
  suggested_action="No failure detected. Keep this report as the baseline evidence for future diff-aware comparisons."
elif [[ -n "$device_signal" ]]; then
  failure_class="device_not_ready"
  failure_domain="infrastructure"
  suggested_action="Fix emulator/device readiness before provisioning fixtures or rerunning the flow."
elif [[ -n "$cleanup_signal" ]]; then
  failure_class="fixture_cleanup_failed"
  if [[ -n "$http_signal" ]]; then
    failure_domain="backend"
  else
    failure_domain="test_harness"
  fi
  suggested_action="Inspect the fixture wrapper cleanup path and backend response before rerunning dependent flows."
elif [[ -n "$http_signal" ]]; then
  failure_class="backend_http_error"
  failure_domain="backend"
  suggested_action="Inspect the API request/response contract near the failing step and compare it with changed data/repository code."
elif [[ "$failure_message $failed_command_message" =~ Home.*visible ]] &&
  rg -q '^Email$|^Password$' "$hierarchy_text_file"; then
  failure_class="input_not_applied"
  failure_domain="test_harness"
  suggested_action="Check whether the flow tapped labels instead of editable fields. Inspect the hierarchy for EditText nodes and use a more specific selector."
elif [[ "$failure_message $failed_command_message" =~ Element\ not\ found|No\ visible\ element|Assertion\ is\ false ]]; then
  failure_class="selector_mismatch"
  failure_domain="test_harness"
  suggested_action="Compare the expected selector with the final hierarchy text. Maestro text selectors are full regular expressions."
elif [[ "$failure_message $failed_command_message" =~ visible|navigate|screen ]]; then
  failure_class="app_did_not_navigate"
  failure_domain="app"
  suggested_action="Inspect navigation/session state and the preceding successful commands."
fi

failed_command_context="$failed_command_type $failed_selector $failed_command_message"
signature_json="$(
  match_failure_signature \
    "$signatures_file" \
    "$failure_class" \
    "$failure_message" \
    "$failed_command_context" \
    "$failed_selector" \
    "$hierarchy_text_file" \
    "$combined_logs_file" \
    "$changed_files_file"
)"
signature_id="$(jq -r '.id // ""' <<<"$signature_json")"
signature_description="$(jq -r '.description // ""' <<<"$signature_json")"
signature_action="$(jq -r '.action // ""' <<<"$signature_json")"
if [[ -n "$signature_action" ]]; then
  suggested_action="$signature_action"
fi

suspicious_files="$(
  if [[ "$failure_class" == "none" ]]; then
    printf '_No failure detected._\n'
  elif [[ -s "$changed_files_file" ]]; then
    case "$failure_class" in
      selector_mismatch|input_not_applied)
        diff_files_matching \
          "$diff_file" \
          '^\.maestro/.*\.ya?ml$' \
          '(^|[[:space:]-])(id|text|idregex|textregex|assertvisible|assertnotvisible|tapon|inputtext|visible)[[:space:]:=(]'
        diff_files_matching \
          "$diff_file" \
          '^lib/.*\.dart$' \
          '(semantics|semanticlabel|semanticslabel|valuekey|key[[:space:]]*:|testid|test_id)'
        rg '^\.maestro/|^tool/agent/' "$changed_files_file" || true
        metadata_owned_files "$changed_files_file" "$flow_owns_file"
        rg '^lib/features/auth/|^lib/features/account/|^lib/navigation/' "$changed_files_file" || true
        ;;
      backend_http_error)
        diff_files_matching \
          "$diff_file" \
          '^lib/(features/.*/data/|core/infra/network/).*\.dart$' \
          '(endpoint|payload|request|response|tojson|fromjson|body|dio|/v[0-9]+/|[.](get|post|put|patch|delete)[(])'
        rg '^lib/features/.*/data/|^lib/core/infra/network/' "$changed_files_file" || true
        metadata_owned_files "$changed_files_file" "$flow_owns_file"
        rg '^tool/agent/' "$changed_files_file" || true
        ;;
      fixture_cleanup_failed)
        diff_files_matching \
          "$diff_file" \
          '^tool/agent/.*\.sh$' \
          '(fixture|cleanup|revoke|revocation|session|logout|api_request|curl)'
        rg '^tool/agent/|^lib/features/.*/data/|^lib/core/infra/network/' "$changed_files_file" || true
        metadata_owned_files "$changed_files_file" "$flow_owns_file"
        ;;
      device_not_ready)
        rg '^tool/agent/|^lib/features/.*/data/|^lib/core/infra/network/' "$changed_files_file" || true
        ;;
      app_did_not_navigate)
        diff_files_matching \
          "$diff_file" \
          '^lib/(navigation/|core/runtime/session/|features/auth/).*\.dart$' \
          '(route|router|redirect|navigator|navigation|session|refreshtoken|accesstoken|logout|authenticated)'
        metadata_owned_files "$changed_files_file" "$flow_owns_file"
        rg '^lib/navigation/|^lib/core/runtime/session/|^lib/features/auth/|^lib/features/account/' "$changed_files_file" || true
        ;;
    esac
    cat "$changed_files_file"
  fi | awk '!seen[$0]++' | head -n 5
)"

if [[ -z "$suspicious_files" ]]; then
  suspicious_files="_No changed files matched deterministic heuristics._"
fi

hierarchy_excerpt="$(
  if [[ -n "$failed_selector" && -s "$hierarchy_text_file" ]]; then
    rg -i -m 8 "$(printf '%s' "$failed_selector" | sed 's/[][(){}.^$*+?|\\]/\\&/g' | cut -c1-40)" \
      "$hierarchy_text_file" 2>/dev/null || true
  fi
)"
if [[ -z "$hierarchy_excerpt" ]]; then
  hierarchy_excerpt="$(head -n 20 "$hierarchy_text_file")"
fi

changed_files_json="$(
  if [[ -s "$changed_files_file" ]]; then
    jq -R -s 'split("\n") | map(select(length > 0))' "$changed_files_file"
  else
    printf '[]'
  fi
)"

flow_owns_json="$(
  if [[ -s "$flow_owns_file" ]]; then
    jq -R -s 'split("\n") | map(select(length > 0))' "$flow_owns_file"
  else
    printf '[]'
  fi
)"

suspicious_files_json="$(
  printf '%s\n' "$suspicious_files" |
    jq -R -s '
	      split("\n")
	      | map(select(length > 0))
	      | map(select(startswith("_No changed files") | not))
	      | map(select(startswith("_No failure detected") | not))
	    '
)"

jq -n \
  --arg runDir "$run_dir" \
  --arg flow "$flow_name" \
  --arg flowFile "$flow_file" \
  --arg flowArea "$flow_area" \
  --arg status "$junit_status" \
  --arg runResult "$run_result" \
  --arg failureClass "$failure_class" \
  --arg failureDomain "$failure_domain" \
  --arg failure "$failure_message" \
  --arg failedCommandType "$failed_command_type" \
  --arg failedSelector "$failed_selector" \
  --arg failedCommandMessage "$failed_command_message" \
  --arg screenshot "$failure_screenshot" \
  --arg httpSignal "$http_signal" \
  --arg cleanupSignal "$cleanup_signal" \
  --arg deviceSignal "$device_signal" \
  --arg suggestedAction "$suggested_action" \
  --argjson signature "$signature_json" \
  --argjson changedFiles "$changed_files_json" \
  --argjson flowOwns "$flow_owns_json" \
  --argjson suspiciousFiles "$suspicious_files_json" \
  '{
    runDir: $runDir,
    flow: $flow,
    flowMetadata: {
      file: $flowFile,
      area: $flowArea,
      owns: $flowOwns
    },
    status: $status,
    runResult: $runResult,
    failureClass: $failureClass,
    failureDomain: $failureDomain,
    failure: $failure,
    failedCommand: {
      type: $failedCommandType,
      selector: $failedSelector,
      message: $failedCommandMessage
    },
    signals: {
      http: $httpSignal,
      cleanup: $cleanupSignal,
      device: $deviceSignal
    },
    screenshot: $screenshot,
    changedFiles: $changedFiles,
    suspiciousFiles: $suspiciousFiles,
    signature: $signature,
    suggestedAction: $suggestedAction
  }' > "$report_json"

{
  echo "# Mobile Failure Report"
  echo
  echo "- Run: \`$run_dir\`"
  echo "- Flow: \`$flow_name\`"
  echo "- Status: \`$junit_status\`"
  echo "- Run result: \`$run_result\`"
  echo "- Failure class: \`$failure_class\`"
  echo "- Failure domain: \`$failure_domain\`"
  if [[ -n "$signature_id" ]]; then
    echo "- Signature: \`$signature_id\`"
  fi
  if [[ -n "$flow_area" || -s "$flow_owns_file" ]]; then
    echo "- Flow metadata: \`${flow_file}\` (area: \`${flow_area:-unknown}\`)"
  fi
  echo
  echo "## Failure"
  echo
  if [[ -n "$failure_message" ]]; then
    echo "$failure_message"
  else
    echo "_No JUnit failure message found._"
  fi
  echo
  echo "## Failed Command"
  echo
  echo "- Type: \`${failed_command_type:-unknown}\`"
  echo "- Selector: \`${failed_selector:-unknown}\`"
  if [[ -n "$failed_command_message" ]]; then
    echo "- Message: \`$failed_command_message\`"
  fi
  echo
  echo "## Actual Screen Evidence"
  echo
  if [[ -n "$failure_screenshot" ]]; then
    echo "- Screenshot: \`$failure_screenshot\`"
  else
    echo "- Screenshot: _none found_"
  fi
  echo
  echo "Hierarchy excerpt:"
  echo
  if [[ -n "$hierarchy_excerpt" ]]; then
    echo '```text'
    printf '%s\n' "$hierarchy_excerpt"
    echo '```'
  else
    echo "_No hierarchy text extracted._"
  fi
  echo
  echo "## Signals"
  echo
  echo "- HTTP/backend: \`${http_signal:-none}\`"
  echo "- Fixture cleanup: \`${cleanup_signal:-none}\`"
  echo "- Device: \`${device_signal:-none}\`"
  if [[ -n "$signature_id" ]]; then
    echo
    echo "## Known Failure Signature"
    echo
    echo "- ID: \`$signature_id\`"
    echo "- Description: $signature_description"
  fi
  echo
  echo "## Most Suspicious Changed Files"
  echo
  if [[ "$suspicious_files" == _No* ]]; then
    echo "$suspicious_files"
  else
    nl -w1 -s'. ' <<<"$suspicious_files"
  fi
  echo
  echo "## Suggested Agent Action"
  echo
  echo "$suggested_action"
} > "$report_md"

echo "Wrote: $report_md"
echo "Wrote: $report_json"
