# Template TODO (Backlog)

This checklist tracks remaining work to make `mobile-core-kit` a safe, enterprise-grade starter template.

## P0 — Safety / Template Hygiene

- [x] Document demo Firebase configuration (template-only)
  - [x] Add callouts in `README.md` and `docs/engineering/firebase_setup.md`.
  - [ ] Optional: add a “prod safety gate” to prevent shipping with demo config.
- [x] Add a “Rename & Rebrand” checklist doc (one place, copy/paste friendly)
  - [x] Add `docs/template/rename_rebrand.md`.
  - [x] Remove personal identifiers from docs examples (use `com.yourcompany.yourapp.*`).
- [x] CI correctness defaults
  - [x] Make CI run on PRs and `push` to `main`.
  - [x] Add `flutter analyze` to CI.

## P1 — Developer Experience / Maintainability

- [x] Add a single “verify” command/script
  - [x] Add `tool/verify.dart` (config generation + analyze + tests + format check).
  - [x] Document it in `README.md`.
- [x] Document `.env/*.yaml` schema in template docs
  - [x] Add `docs/template/env_config.md`.
- [x] Clean remaining placeholders / dated messaging
  - [x] Replace “XXX app” phrasing in `lib/core/utilities/log_utils.dart`.
  - [x] Reword `README.md` status line to be timeless.

## P2 — Enterprise Polish

- [ ] Add an iOS CI lane (build + tests; signing stays adopter-owned)
- [ ] Add `integration_test/` skeleton for critical flows
  - [ ] Startup gate readiness + deep link resume through onboarding/auth
  - [ ] Basic auth happy path
