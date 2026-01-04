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

- [ ] Add a single “verify” command/script
  - [ ] Runs: `flutter pub get`, `dart run tool/gen_config.dart --env <env>`, `flutter analyze`, `flutter test`, `dart format --set-exit-if-changed .`
  - [ ] Document it in `README.md`.
- [ ] Document `.env/*.yaml` schema in template docs
  - [ ] List keys, types, defaults, and what code consumes each value.
  - [ ] Clarify which values are safe to commit vs must be secret.
- [ ] Clean remaining placeholders / dated messaging
  - [ ] Replace “XXX app” phrasing in logging/docs.
  - [ ] Reword `README.md` “work in progress” section to be timeless (avoid date-based milestones).

## P2 — Enterprise Polish

- [ ] Add an iOS CI lane (build + tests; signing stays adopter-owned)
- [ ] Add `integration_test/` skeleton for critical flows
  - [ ] Startup gate readiness + deep link resume through onboarding/auth
  - [ ] Basic auth happy path
