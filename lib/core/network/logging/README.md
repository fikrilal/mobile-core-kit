# Network Logging (Console-Only)

This folder contains the console-only network logging utilities used by the Dio `LoggingInterceptor`.
The goal is to keep terminal output clean and useful while preserving full visibility in Flutter DevTools.

## What It Does
- Prints one-line summaries for each request: easy to scan and filter.
- Optionally prints response bodies in a controlled way (size limits, slow/error rules).
- Redacts sensitive data (headers and body fields) before logging.
- Adds a correlation ID to tie related logs together.
- Never writes logs to files (console-only by design).

## Modes
Defined in `net_log_mode.dart`:
- `off`: No network logs.
- `summary`: One-line summary per request; never prints bodies.
- `smallBodies`: Summary + print body only when small, slow, or error (truncated to limit when necessary).
- `full`: Summary + always print body (truncated to limit).

Tip: Use `summary` in development as a default; use `off` in production.

## Summary Format
```
METHOD /path → STATUS in X ms (Y KB) [TAGS] [corrId=<id>]
```
Examples:
- `GET /v1/products → 200 in 120 ms (4.0 KB) [GET] [corrId=ab12]`
- `POST /v1/checkout → 200 in 1450 ms (9.0 KB) [POST][SLOW] [corrId=cd34]`
- `GET /v1/profile → 500 in 320 ms (2.0 KB) [GET][ERROR] [corrId=ef56]`

Tags can include: `GET`, `POST`, `SLOW`, `ERROR`, and `SMALL` (when the payload is within the body limit).

## Body Logging Rules
- In `summary` and `off`: bodies are not printed.
- In `smallBodies`:
  - Print body when any of these is true: status >= 400 (error), duration > `slowMs` (slow), or size <= `bodyLimitBytes` (small).
  - If large, body is skipped.
- In `full`: bodies always printed, but truncated to `bodyLimitBytes`.

Truncation is done by bytes and appends `… (truncated)` when applied.

## Redaction
Implemented in `redactor.dart`.
- Header keys (case-insensitive) masked by default: `authorization`, `cookie`, `set-cookie`, `x-api-key`, `x-auth-token`, `x-access-token`.
- Body keys (best-effort, recursive): `password`, `token`, `otp`, `pin`, `email`.
- Mask format keeps minimal context (e.g., `abc***xyz`).

## Configuration
Set via `.env.dev` / `.env.prod` and initialized in `main_*.dart`:
- `NET_LOG_MODE`: `off|summary|smallBodies|full`
- `NET_LOG_BODY_LIMIT_BYTES`: default 8192
- `NET_LOG_LARGE_THRESHOLD_BYTES`: default 65536 (used for size classification/labels)
- `NET_LOG_SLOW_MS`: default 800
- `NET_LOG_REDACT`: `true|false` (default true)

`NetworkLogConfig.init(...)` is called in both `main_dev.dart` and `main_prod.dart`. Adjust env values to change behavior without code changes.

## Using The Interceptor
`lib/core/network/interceptors/logging_interceptor.dart`
- Add to Dio interceptors (order suggestion):
  1) `BaseUrlInterceptor`
  2) `HeaderInterceptor`
  3) `AuthInterceptor` (if used)
  4) `LoggingInterceptor` (so it sees final URL/headers)
  5) `ErrorInterceptor`

Example:
```dart
final dio = Dio();
dio.interceptors.addAll([
  BaseUrlInterceptor(),
  HeaderInterceptor(),
  AuthInterceptor(),
  LoggingInterceptor(),
  ErrorInterceptor(),
]);
```

### Optional: In-app Network Inspector (Dev)
This project supports the `requests_inspector` package in development for an on-device inspector.

- Enabled via `.env.dev`:
  - `NET_INSPECTOR_ENABLED=true`
  - `NET_INSPECTOR_TRIGGER=both` (options: `shake|longpress|both`)
- `main_dev.dart` wraps `MyApp` with `RequestsInspector` when enabled.
- To inspect Dio traffic inside the inspector, add its interceptor where you build Dio:

```dart
import 'package:requests_inspector/requests_inspector.dart';

final dio = Dio();
dio.interceptors.add(RequestsInspectorInterceptor());
```

Keep `NET_INSPECTOR_ENABLED=false` for production builds.

## DevTools Visibility
- These modes affect only console logging. Network requests remain fully visible in Flutter DevTools (Network tab) because Dio uses `dart:io` instrumentation.
- On Web builds, use the browser Network panel. The console policy doesn’t interfere.

## Troubleshooting
- Seeing too much output? Set `NET_LOG_MODE=summary` and reduce `NET_LOG_BODY_LIMIT_BYTES`.
- Need more detail for debugging? Temporarily use `NET_LOG_MODE=full` in development.
- Sensitive data showing up? Ensure `NET_LOG_REDACT=true` (default) and review any custom body structures.
- Mixed logs? Filter by logger name `network` in your log viewer or IDE.

## Future Ideas (Optional)
- Tag `[TRUNCATED]` explicitly when bodies are cut at the limit.
- In-app network inspector using an in-memory ring buffer (dev-only).
- Per-endpoint overrides for logging policy.
