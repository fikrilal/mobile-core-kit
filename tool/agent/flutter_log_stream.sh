#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  tool/agent/flutter_log_stream.sh <command> [options]

Commands:
  start    Start a background Flutter log stream session.
  status   Show session status and artifact paths.
  tail     Print the latest lines from the session log file.
  stop     Stop a running session.

Common options:
  --session <name>         Session name (default: default).
  --artifacts-dir <path>   Base artifacts directory (default: _artifacts/runtime_logs).

Start options:
  --mode <logs|run>        logs: attach to device logs, run: launch app then stream logs (default: logs).
  --device <id>            Flutter device id.
  --flavor <name>          Flavor for run mode (default: dev).
  --target <path>          Entry file for run mode (default: lib/main_dev.dart).
  -- <args...>             Extra args forwarded to Flutter.

Tail options:
  --lines <n>              Number of lines to print (default: 120).

Examples:
  tool/agent/flutter_log_stream.sh start --session emulator --mode logs --device emulator-5554
  tool/agent/flutter_log_stream.sh start --session dev-run --mode run --device emulator-5554 --flavor dev --target lib/main_dev.dart
  tool/agent/flutter_log_stream.sh tail --session emulator --lines 200
  tool/agent/flutter_log_stream.sh stop --session emulator
EOF
}

ensure_session_name() {
  local session_name="$1"
  if [[ -z "$session_name" || ! "$session_name" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "ERROR: Invalid session name '$session_name'. Use [A-Za-z0-9._-]." >&2
    exit 2
  fi
}

is_pid_running() {
  local pid="$1"
  [[ -n "$pid" ]] && kill -0 "$pid" >/dev/null 2>&1
}

resolve_flutter_cmd() {
  local script_dir="$1"
  if command -v cmd.exe >/dev/null 2>&1 && [[ -f "$script_dir/flutterw" ]]; then
    printf '%s\n' "bash" "$script_dir/flutterw" "--no-stdin"
    return
  fi

  if ! command -v flutter >/dev/null 2>&1; then
    echo "ERROR: flutter command not found in PATH." >&2
    exit 1
  fi
  printf '%s\n' "flutter"
}

command_name="${1:-}"
if [[ -z "$command_name" ]]; then
  usage
  exit 2
fi
if [[ "$command_name" == "-h" || "$command_name" == "--help" ]]; then
  usage
  exit 0
fi
shift || true

session="default"
artifacts_dir="_artifacts/runtime_logs"
mode="logs"
device=""
flavor="dev"
target="lib/main_dev.dart"
lines="120"
extra_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --session)
      [[ $# -ge 2 ]] || { echo "ERROR: --session requires a value." >&2; exit 2; }
      session="$2"
      shift 2
      ;;
    --artifacts-dir)
      [[ $# -ge 2 ]] || { echo "ERROR: --artifacts-dir requires a value." >&2; exit 2; }
      artifacts_dir="$2"
      shift 2
      ;;
    --mode)
      [[ $# -ge 2 ]] || { echo "ERROR: --mode requires a value." >&2; exit 2; }
      mode="$2"
      shift 2
      ;;
    --device)
      [[ $# -ge 2 ]] || { echo "ERROR: --device requires a value." >&2; exit 2; }
      device="$2"
      shift 2
      ;;
    --flavor)
      [[ $# -ge 2 ]] || { echo "ERROR: --flavor requires a value." >&2; exit 2; }
      flavor="$2"
      shift 2
      ;;
    --target)
      [[ $# -ge 2 ]] || { echo "ERROR: --target requires a value." >&2; exit 2; }
      target="$2"
      shift 2
      ;;
    --lines)
      [[ $# -ge 2 ]] || { echo "ERROR: --lines requires a value." >&2; exit 2; }
      lines="$2"
      shift 2
      ;;
    --)
      shift
      extra_args=( "$@" )
      break
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

ensure_session_name "$session"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../.." && pwd)"
fi
cd "$repo_root"

session_dir="$artifacts_dir/$session"
pid_file="$session_dir/stream.pid"
log_file="$session_dir/stream.log"
metadata_file="$session_dir/metadata.env"
command_file="$session_dir/command.txt"

case "$command_name" in
  start)
    case "$mode" in
      logs|run) ;;
      *)
        echo "ERROR: Invalid --mode '$mode'. Expected logs or run." >&2
        exit 2
        ;;
    esac

    mkdir -p "$session_dir"

    if [[ -f "$pid_file" ]]; then
      existing_pid="$(tr -d '[:space:]' < "$pid_file")"
      if is_pid_running "$existing_pid"; then
        echo "ERROR: Session '$session' is already running (pid=$existing_pid)." >&2
        echo "Use: tool/agent/flutter_log_stream.sh stop --session $session" >&2
        exit 1
      fi
      rm -f "$pid_file"
    fi

    mapfile -t flutter_cmd < <(resolve_flutter_cmd "$script_dir")
    cmd=( "${flutter_cmd[@]}" )

    if [[ "$mode" == "logs" ]]; then
      cmd+=( logs )
      if [[ -n "$device" ]]; then
        cmd+=( -d "$device" )
      fi
      cmd+=( "${extra_args[@]}" )
    else
      cmd+=( run )
      if [[ -n "$device" ]]; then
        cmd+=( -d "$device" )
      fi
      cmd+=( --flavor "$flavor" -t "$target" "--dart-define=ENV=$flavor" )
      cmd+=( "${extra_args[@]}" )
    fi

    {
      printf '[%s] START session=%s mode=%s\n' "$(date -Iseconds)" "$session" "$mode"
      printf '[%s] CMD ' "$(date -Iseconds)"
      printf '%q ' "${cmd[@]}"
      printf '\n'
    } >> "$log_file"

    (
      exec "${cmd[@]}" >> "$log_file" 2>&1
    ) &
    stream_pid="$!"
    echo "$stream_pid" > "$pid_file"

    {
      echo "session=$session"
      echo "mode=$mode"
      echo "device=$device"
      echo "flavor=$flavor"
      echo "target=$target"
      echo "pid=$stream_pid"
      echo "started_at=$(date -Iseconds)"
      echo "repo_root=$repo_root"
      echo "log_file=$log_file"
    } > "$metadata_file"

    printf '%q ' "${cmd[@]}" > "$command_file"
    printf '\n' >> "$command_file"

    sleep 1
    if ! is_pid_running "$stream_pid"; then
      echo "ERROR: Stream process exited immediately. Check log: $log_file" >&2
      tail -n 40 "$log_file" >&2 || true
      rm -f "$pid_file"
      exit 1
    fi

    echo "Started session '$session' (pid=$stream_pid)."
    echo "Log file: $log_file"
    ;;

  status)
    echo "session=$session"
    echo "session_dir=$session_dir"
    echo "log_file=$log_file"

    if [[ ! -f "$pid_file" ]]; then
      echo "status=stopped"
      exit 0
    fi

    status_pid="$(tr -d '[:space:]' < "$pid_file")"
    if is_pid_running "$status_pid"; then
      echo "status=running"
      echo "pid=$status_pid"
      if [[ -f "$metadata_file" ]]; then
        echo "metadata_file=$metadata_file"
      fi
    else
      echo "status=stopped"
      echo "stale_pid=$status_pid"
    fi
    ;;

  tail)
    if [[ ! "$lines" =~ ^[0-9]+$ ]]; then
      echo "ERROR: --lines must be a non-negative integer." >&2
      exit 2
    fi

    if [[ ! -f "$log_file" ]]; then
      echo "ERROR: Log file not found for session '$session': $log_file" >&2
      exit 1
    fi
    tail -n "$lines" "$log_file"
    ;;

  stop)
    if [[ ! -f "$pid_file" ]]; then
      echo "Session '$session' is not running."
      exit 0
    fi

    stop_pid="$(tr -d '[:space:]' < "$pid_file")"
    if ! is_pid_running "$stop_pid"; then
      rm -f "$pid_file"
      echo "Session '$session' had stale pid=$stop_pid. Cleaned pid file."
      exit 0
    fi

    kill "$stop_pid" >/dev/null 2>&1 || true
    for _ in {1..20}; do
      if ! is_pid_running "$stop_pid"; then
        break
      fi
      sleep 0.2
    done

    if is_pid_running "$stop_pid"; then
      kill -9 "$stop_pid" >/dev/null 2>&1 || true
    fi

    rm -f "$pid_file"
    printf '[%s] STOP session=%s pid=%s\n' "$(date -Iseconds)" "$session" "$stop_pid" >> "$log_file"
    echo "Stopped session '$session' (pid=$stop_pid)."
    ;;

  *)
    echo "ERROR: Unknown command '$command_name'." >&2
    usage
    exit 2
    ;;
esac
