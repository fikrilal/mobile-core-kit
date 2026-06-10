#!/usr/bin/env python3
"""Run-scoped HTTP proxy that forces one access-token refresh."""

from __future__ import annotations

import argparse
import base64
import hashlib
import http.client
import json
import os
import signal
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


HOP_BY_HOP_HEADERS = {
    "connection",
    "content-length",
    "host",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailers",
    "transfer-encoding",
    "upgrade",
}


class RefreshFaultState:
    def __init__(self, status_file: Path) -> None:
        self._status_file = status_file
        self._lock = threading.Lock()
        self.injected = False
        self.refresh_count = 0
        self.replay_observed = False
        self.session_id = ""
        self._initial_token_hash = ""
        self.write()

    def try_inject(self, token: str) -> bool:
        with self._lock:
            if self.injected:
                return False
            self.injected = True
            self._initial_token_hash = _token_hash(token)
            self.session_id = _jwt_session_id(token)
            self.write()
            return True

    def record_refresh(self) -> None:
        with self._lock:
            self.refresh_count += 1
            self.write()

    def record_replay(self, token: str) -> None:
        with self._lock:
            if self.injected and _token_hash(token) != self._initial_token_hash:
                self.replay_observed = True
                self.write()

    def snapshot(self) -> dict[str, object]:
        return {
            "injected401": self.injected,
            "refreshCount": self.refresh_count,
            "replayObserved": self.replay_observed,
            "sessionId": self.session_id,
        }

    def write(self) -> None:
        self._status_file.parent.mkdir(parents=True, exist_ok=True)
        fd, temp_path = tempfile.mkstemp(
            dir=self._status_file.parent,
            prefix=f".{self._status_file.name}.",
        )
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as output:
                json.dump(self.snapshot(), output, separators=(",", ":"))
                output.write("\n")
            os.replace(temp_path, self._status_file)
        finally:
            if os.path.exists(temp_path):
                os.unlink(temp_path)


def _token_hash(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def _jwt_session_id(token: str) -> str:
    try:
        payload = token.split(".")[1]
        payload += "=" * (-len(payload) % 4)
        decoded = json.loads(base64.urlsafe_b64decode(payload))
        session_id = decoded.get("sid")
        return session_id if isinstance(session_id, str) else ""
    except (IndexError, ValueError, json.JSONDecodeError):
        return ""


def _bearer_token(headers: object) -> str:
    authorization = headers.get("Authorization", "")
    if not authorization.startswith("Bearer "):
        return ""
    return authorization.removeprefix("Bearer ").strip()


def create_handler(
    upstream: str,
    state: RefreshFaultState,
) -> type[BaseHTTPRequestHandler]:
    parsed_upstream = urlsplit(upstream)
    connection_type = (
        http.client.HTTPSConnection
        if parsed_upstream.scheme == "https"
        else http.client.HTTPConnection
    )
    upstream_base_path = parsed_upstream.path.rstrip("/")

    class RefreshFaultProxyHandler(BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def do_GET(self) -> None:
            token = _bearer_token(self.headers)
            request_path = urlsplit(self.path).path
            if (
                request_path == "/v1/me/sessions"
                and token
                and state.try_inject(token)
            ):
                body = json.dumps(
                    {
                        "type": "about:blank",
                        "title": "Unauthorized",
                        "status": 401,
                        "code": "AUTH_ACCESS_TOKEN_INVALID",
                        "detail": "Run-scoped refresh fixture rejected the access token.",
                    },
                    separators=(",", ":"),
                ).encode()
                self.send_response(401)
                self.send_header("Content-Type", "application/problem+json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
                return

            if request_path == "/v1/me/sessions" and token:
                state.record_replay(token)
            self._forward()

        def do_POST(self) -> None:
            if urlsplit(self.path).path == "/v1/auth/refresh":
                state.record_refresh()
            self._forward()

        def do_PUT(self) -> None:
            self._forward()

        def do_PATCH(self) -> None:
            self._forward()

        def do_DELETE(self) -> None:
            self._forward()

        def do_HEAD(self) -> None:
            self._forward()

        def do_OPTIONS(self) -> None:
            self._forward()

        def _forward(self) -> None:
            body_length = int(self.headers.get("Content-Length", "0"))
            body = self.rfile.read(body_length) if body_length else None
            headers = {
                key: value
                for key, value in self.headers.items()
                if key.lower() not in HOP_BY_HOP_HEADERS
            }
            path = f"{upstream_base_path}{self.path}"
            connection = connection_type(
                parsed_upstream.hostname,
                parsed_upstream.port,
                timeout=30,
            )
            try:
                connection.request(self.command, path, body=body, headers=headers)
                response = connection.getresponse()
                response_body = response.read()
                self.send_response(response.status)
                for key, value in response.getheaders():
                    if key.lower() not in HOP_BY_HOP_HEADERS:
                        self.send_header(key, value)
                self.send_header("Content-Length", str(len(response_body)))
                self.end_headers()
                if self.command != "HEAD":
                    self.wfile.write(response_body)
            finally:
                connection.close()

        def log_message(self, format_string: str, *args: object) -> None:
            print(
                f"{self.address_string()} - {format_string % args}",
                flush=True,
            )

    return RefreshFaultProxyHandler


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--listen-host", default="127.0.0.1")
    parser.add_argument("--listen-port", type=int, required=True)
    parser.add_argument("--upstream", required=True)
    parser.add_argument("--status-file", type=Path, required=True)
    args = parser.parse_args()

    state = RefreshFaultState(args.status_file)
    server = ThreadingHTTPServer(
        (args.listen_host, args.listen_port),
        create_handler(args.upstream, state),
    )
    signal.signal(
        signal.SIGTERM,
        lambda *_: threading.Thread(target=server.shutdown, daemon=True).start(),
    )
    server.serve_forever()


if __name__ == "__main__":
    main()
