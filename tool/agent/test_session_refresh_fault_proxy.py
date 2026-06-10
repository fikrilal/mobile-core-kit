#!/usr/bin/env python3

from __future__ import annotations

import base64
import json
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from session_refresh_fault_proxy import RefreshFaultState, create_handler


class _UpstreamHandler(BaseHTTPRequestHandler):
    refresh_count = 0

    def do_GET(self) -> None:
        body = b'{"data":[{"current":true}]}'
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self) -> None:
        type(self).refresh_count += 1
        body = b'{"data":{"refreshed":true}}'
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_PUT(self) -> None:
        self.send_response(204)
        self.send_header("Content-Length", "0")
        self.end_headers()

    def log_message(self, *_: object) -> None:
        pass


def _token(session_id: str, marker: str) -> str:
    header = base64.urlsafe_b64encode(b'{"alg":"none"}').decode().rstrip("=")
    payload = (
        base64.urlsafe_b64encode(
            json.dumps({"sid": session_id, "marker": marker}).encode()
        )
        .decode()
        .rstrip("=")
    )
    return f"{header}.{payload}.signature"


class SessionRefreshFaultProxyTest(unittest.TestCase):
    def setUp(self) -> None:
        _UpstreamHandler.refresh_count = 0
        self.upstream = ThreadingHTTPServer(("127.0.0.1", 0), _UpstreamHandler)
        threading.Thread(target=self.upstream.serve_forever, daemon=True).start()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.status_file = Path(self.temp_dir.name) / "status.json"
        self.state = RefreshFaultState(self.status_file)
        upstream_url = f"http://127.0.0.1:{self.upstream.server_port}"
        self.proxy = ThreadingHTTPServer(
            ("127.0.0.1", 0),
            create_handler(upstream_url, self.state),
        )
        threading.Thread(target=self.proxy.serve_forever, daemon=True).start()
        self.proxy_url = f"http://127.0.0.1:{self.proxy.server_port}"

    def tearDown(self) -> None:
        self.proxy.shutdown()
        self.proxy.server_close()
        self.upstream.shutdown()
        self.upstream.server_close()
        self.temp_dir.cleanup()

    def request(self, path: str, token: str, method: str = "GET") -> int:
        request = Request(
            f"{self.proxy_url}{path}",
            method=method,
            headers={"Authorization": f"Bearer {token}"},
        )
        try:
            with urlopen(request) as response:
                response.read()
                return response.status
        except HTTPError as error:
            error.read()
            return error.code

    def test_injects_once_and_records_refresh_and_replay(self) -> None:
        old_token = _token("session-123", "old")
        new_token = _token("session-123", "new")

        self.assertEqual(self.request("/v1/me/push-token", old_token, "PUT"), 204)
        self.assertEqual(self.request("/v1/me/sessions", old_token), 401)
        self.assertEqual(self.request("/v1/auth/refresh", old_token, "POST"), 200)
        self.assertEqual(self.request("/v1/me/sessions", new_token), 200)

        status = json.loads(self.status_file.read_text())
        self.assertEqual(
            status,
            {
                "injected401": True,
                "refreshCount": 1,
                "replayObserved": True,
                "sessionId": "session-123",
            },
        )
        self.assertNotIn(old_token, self.status_file.read_text())
        self.assertNotIn(new_token, self.status_file.read_text())


if __name__ == "__main__":
    unittest.main()
