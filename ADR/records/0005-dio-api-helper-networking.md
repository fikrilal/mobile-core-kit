---
status: "accepted"
date: 2025-12-12
decision-makers: [Mobile Core Kit maintainers]
consulted: [Mobile Engineers]
informed: [All contributors]
scope: template
tags: [networking, dio, interceptors]
---

# Dio Networking via ApiClient + ApiHelper + Interceptors

## Context and Problem Statement

Multiple features will talk to HTTP APIs with authentication, multi‑host support, consistent error mapping, and optional logging. We need a network layer that provides these cross‑cutting concerns once and keeps feature code focused on request/response modeling.

## Decision Drivers

* Centralized auth token attachment and refresh handling.
* Multi‑host base URL switching per request.
* Unified error translation into domain failures.
* Configurable request/response logging by environment.
* Feature‑friendly typed helpers for common patterns (lists, pagination).

## Considered Options

* Use `package:http` with ad‑hoc helpers per feature.
* Use Retrofit/Chopper directly in each feature.
* Use Dio with a shared ApiClient/ApiHelper stack (chosen).

## Decision Outcome

Chosen option: **Dio with shared `ApiClient` and `ApiHelper` plus interceptors**, because it centralizes cross‑cutting behavior while keeping remote datasources concise.

Pattern:

* `ApiClient` (`lib/core/network/api/api_client.dart`) owns Dio and interceptor order.
* Interceptors handle base URL, headers, auth token, logging, and error normalization.
* `ApiHelper` provides typed `get/post/put/delete` with parsers and pagination helpers.
* Features call `ApiHelper` from remote datasources and map DTOs → entities in repositories.

### Consequences

* Good, because auth, logging, and errors are consistent across the app.
* Good, because features stay simple and testable.
* Neutral, because interceptor order must be maintained carefully.
* Bad, because bypassing `ApiHelper` in features risks inconsistent behavior.

### Confirmation

Confirmed when:

* New remote datasources use `ApiHelper` rather than creating their own Dio clients.
* Interceptor changes include an ADR if they alter cross‑feature behavior.

