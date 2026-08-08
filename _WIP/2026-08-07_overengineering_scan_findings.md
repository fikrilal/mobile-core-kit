# Over-Engineering Scan Findings

Date: 2026-08-07
Status: Draft
Scope: `packages/mobile_core_kit_cli/`, `packages/mobile_core_kit_lints/`, `lib/core/`, `lib/features/`, `lib/navigation/`, `duplication/`, `lint/`

Evaluation rule applied (per `AGENTS.md`): *"Simplicity First — minimum code that solves the problem, nothing speculative."* Findings are verified against production callers (`lib/`, `.github/`, docs); line numbers are approximate. Findings that are template-by-design (clean-architecture layering, Freezed codegen, showcase screens) are called out in the fairness notes rather than flagged.

---

## Tooling Layer (`packages/mobile_core_kit_cli`, `packages/mobile_core_kit_lints`)

### 1. `DuplicationReportFilter` — ~700 lines of heuristic category-guessing

**File:** `packages/mobile_core_kit_cli/lib/src/duplication/duplication_report_filter.dart`

After jscpd emits JSON, this filter re-parses the report, guesses *why* each duplicate exists via regex heuristics (`_categorizeCore`, `_categorizeSmallHelpers`, `_categorizePresentation`, lines ~245–547), matches the guess against hand-maintained JSON allowlists, groups into `_ActionableGroup`/`_ReviewedGroup` (lines 653–699 — byte-for-byte identical classes except one carries an allowlist entry), and prints a summary.

Why it looks over-engineered:
- No caller depends on any of it. `duplication check` and `verify` only run jscpd + this filter, whose only effect is a human-readable summary and a 0/1 exit code. The gates that matter never parse the groups.
- 13 category enums + 30+ regexes + two parallel group classes, all to decide whether an allowlist entry "matches" — while the allowlist is keyed on (path, path) pairs, making the category a redundant second criterion.
- `fatalFound` parameter (line 21) is never passed `true` — dead parameter.

Suggested simplification: delete `duplication_report_filter.dart` and the three allowlist JSONs; run jscpd with a single config and use its own `--failOn`/exit code. jscpd's console reporter provides the human-readable summary.

### 2. Six custom_lint rules that are the same lint with a different token name

**Files:** `packages/mobile_core_kit_lints/lib/src/{spacing_tokens,radius_tokens,icon_size_tokens,state_opacity_tokens,motion_durations,hardcoded_font_sizes}.dart` (+ partially `hardcoded_ui_colors.dart`, `manual_text_scaling.dart`, `hardcoded_ui_strings.dart`)

Each rule copies verbatim: `_ProjectRootFinder` (~11 lines), `_PathConfig` + `_readGlobList`, `_normalizePath`, `_isGeneratedDart`, `_shorten`, and an AST visitor. The per-file differences are a visitor (~15–45 lines) plus a `_code` constant.

Suggested simplification: extract one shared `TokenLintRule` base (or `_shared.dart`) and express each lint as a small visitor + config. Removes ~60–70% of the lines in these 9 files with zero behavior change. Also note `architecture_imports.dart` has a *different*, cached + package-config-aware `_ProjectRootFinder` — two solutions to one problem living side by side.

### 3. Guardrail checks duplicated as both custom_lint rules *and* regex scanners

**Files:** CLI `lib/src/guardrails/modal_entrypoints_check.dart` (197 lines) + `hardcoded_ui_colors_check.dart` (218 lines) vs lints `lib/src/modal_entrypoints.dart` (139 lines) + `hardcoded_ui_colors.dart` (158 lines)

Two independent implementations of the same two policies, both wired into `verify` (which also runs custom_lint via `LintWorkflow`). Both re-implement comment stripping by hand. The CLI regex versions are strictly worse at the job than the AST rules already running.

Suggested simplification: delete the two CLI guardrail scanners (~415 lines); `verify` already runs custom_lint, so the lint rules remain the single source of truth.

### 4. `fix` workflow duplicates the fix half of `verify`

**Files:** `lib/src/workflows/fix_workflow.dart` (85 lines) vs `lib/src/workflows/verify_workflow.dart` lines 66–84

`FixWorkflow` runs `dart fix --apply --code directives_ordering` + `dart format .`; `verify --apply-fixes` runs the identical two commands. `fix` has zero callers anywhere (no CI, no docs, no proposal).

Suggested simplification: delete `FixWorkflow`, or have `verify --apply-fixes` delegate to a shared `applyFixes(context)` helper.

### 5. `verify` flags that exist only to be tested; env list triplicated

**File:** `lib/src/workflows/verify_workflow.dart` (171 lines)

- `--skip-duplication`, `--skip-format`, `--skip-tests` are used only in tests (`workflow_test.dart:51–53`) — test-only affordances smuggled into the CLI surface. The canonical gate (`verify --env prod --check-codegen`) never skips anything.
- `--apply-fixes` and `--check-codegen`: only `--check-codegen` has a CI caller (`android.yml:111`).
- Env allowlist `{dev, staging, prod}` is written three times: `verify_workflow.dart:35–41`, `build_config_workflow.dart:14`, `environment_schema_workflow.dart:9`. Adding an env means touching three files.

Suggested simplification: drop the skip flags (or move to a test-only constructor), and move the env list into one shared constant.

### 6. Three `.jscpd.*.json` configs differing by 2 lines + hand-maintained allowlists

**Files:** `.jscpd.json`, `.jscpd.small_helpers.json`, `.jscpd.presentation.json`, `duplication/*.json`

The three profiles are "same config, different thresholds" (`minLines` 7→8, `minTokens` 60→50); one config + `--min-lines/--min-tokens` overrides replaces all three. `small_helper_duplication_allowlist.json` is empty (`[]`) — pure bookkeeping ceremony since code already treats a missing file as "no allowlist". Hand-edited `reviewedOn` timestamps are read by nothing except the summary printer.

### 7. `TemplatePlan`/`TemplateLifecycleResult`/`TemplateCustomizationResult` — three result types for one outcome

**Files:** `lib/src/template/template_plan.dart` (91 lines), `template_workflow.dart:108–162`, `template_customization_engine.dart:101–128`

Two result classes derive the exit code from the same enum; `hasChanges`/`hasConflicts` getters are duplicated over the same lists. Collapse to one result type (or return ints). ~60–80 lines of indirection.

### 8. Minor tooling findings

- `runtime logs`/`runtime evidence`: real, documented features (referenced by AGENTS.md risk policy) — keep, but the two process wrappers duplicate the tee-to-log-and-sink pattern (`runtime_log_session.dart:108–128` vs `runtime_evidence_process.dart:58–67`); share one helper.
- `ProjectMapWorkflow` parses AGENTS.md's ASCII tree with regexes and magic break-conditions; it currently self-skips (exec-plan `2026-08-01_mobilekit-cli-foundation.md:78`). If the gate has value, generate the tree rather than parse it; otherwise drop it.
- `.env` parsing helpers duplicated between `build_config_workflow.dart` and `environment_schema_workflow.dart` (near-duplicate `stringLiteral`/`_stringValue` etc.). Extract one `EnvConfigReader`.

---

## Core Layer (`lib/core/`, `lib/navigation/`)

### 1. `AppButton` — one widget, 6 near-duplicated 40-param constructors

**File:** `lib/core/design_system/widgets/button/app_button.dart` (~400 lines)

A full constructor plus `.primary/.secondary/.outline/.danger` named constructors each re-declare ~35 identical parameters and each implement the whole build logic. Every feature call site uses exactly `AppButton.primary/.outline/.danger`; no caller passes `variant:`. Zero production uses of: `hapticFeedback`, `onHover`, `onLongPress`, `focusNode`, `autofocus`, `onFocusChange`, `excludeFromSemantics`, `tooltip`, `width`, `padding`, `margin`, `iconSize`, `iconSpacing`, `loadingIndicator`, `loadingIndicatorSize`, `suffixIcon`, `borderColor`, `textColor`, `fontWeight`. `ButtonState` enum is entirely unused.

Suggested simplification: one constructor with the used params (`text`, `onPressed`, `isLoading`, `isDisabled`, `isExpanded`, `icon`, `semanticLabel`, `loadingText`, `variant`). Removes ~300 lines and the dead enum.

### 2. Adaptive module's speculative surface

**Files:** `lib/core/design_system/adaptive/` — `adaptive_region.dart`, `adaptive_overrides.dart`, `adaptive_split_view.dart`, `adaptive_grid.dart`, `min_tap_target.dart`, `show_adaptive_side_sheet.dart`, `foldables/` package, `adaptive_spec_builder.dart`

Zero production callers (only the module's own tests/READMEs/showcases): `AdaptiveRegion`, `AdaptiveOverrides`, `AdaptiveGrid`, `MinTapTarget`, `AdaptiveSplitView`, `showAdaptiveSideSheet`, `NavigationPolicy.none`, the `foldables/` subpackage (dual-screen hinge geometry for a device class nothing targets), and context accessors `adaptiveInsets/adaptiveText/adaptiveMotion/adaptiveInput/adaptivePlatform/adaptiveFoldable`.

Only 5 spec aspects are actually consumed: `layout`, `navigation` (via `AdaptiveScaffold`), `modal` (via `showAdaptiveModal`), and the root `textScalePolicy`. The per-aspect `InheritedModel` dependency-key machinery (~35 lines) exists for consumers that don't exist.

Suggested simplification: keep `AdaptiveScope` + `AdaptiveScaffold` + `AppPageContainer` + `showAdaptiveModal`; delete the rest (~12 files, ~1500 lines). Add foldable/split-view support back only when a product surface needs it.

### 3. `ApiHelper` unused wrappers + `pagination_utils.dart` + unused `ApiResponse` helpers

**File:** `lib/core/infra/network/api/api_helper.dart` (lines 69–680); `pagination_utils.dart`

Zero callers in `lib/`: `postPaginated`, `postFlexible`, `getList`, `DomainCursorPagination`, `PaginatedDomain`, `mapPaginatedResult`, `ApiResponse.getFieldError/getFieldErrors/generalErrors`, `ApiPaginatedResult.fromEnvelope` (the sessions feature maps pagination inline in `me_session_model.dart:69`). Options `checkConnectivity`/`requiresAuth` default to true and no caller overrides them; `onSendProgress`/`onReceiveProgress`/`cancelToken` never passed.

Suggested simplification: keep `getOne`/`getPaginated`/`post`/`put`/`delete` with only the used options; delete the rest (~halves the file).

### 4. Zero-production widget groups

**Files:** `lib/core/design_system/widgets/search/` (`AppSearchExperience`, `AppSearchInputShell`, `AppSearchStyle`, `AppSearchPalette`, ~400 lines), `widgets/filter_chips/` (`AppFilterChipsBar`, ~200 lines), `navigation/app_bottom_nav_bar.dart` (~60 lines)

No feature imports them; real filter/list screens use `AppPaginatedCollectionView`. They exist only in dev-tool showcases and their own tests. ~650 lines of speculative infrastructure.

### 5. Custom render-object shimmer

**Files:** `lib/core/design_system/widgets/shimmer/` (`shimmer_render.dart`, `shimmer_component.dart`, `shimmer_shapes.dart`, ~450 lines)

A hand-written `RenderProxyBox`/shader pipeline whose only production consumer is `me_sessions_skeleton.dart` using just `ShimmerComponent(child: ListView...)`. `ShimmerBox`/`ShimmerCircle`/`ShimmerText`, `fromColors`, `direction`, `loop`/`enabled` options, and the custom render object are unused elsewhere.

Suggested simplification: replace with a simple animated-gradient wrapper (~40 lines) and delete the render object + shape helpers.

### 6. Smaller core findings

- **`AppTextField`** (`widgets/field/app_textfield.dart`): mirrors the button problem — 5 named constructors, ~45 params each; features use `fieldType`/`labelText`/`errorText`/`onChanged` only. `visualState`, `FieldState.success|warning`, `prefix`/`suffix` slots, `labelPosition`, `restorationId`, `autofillHints`, haptics, `onFocusChange`, `FieldVariant.primary/secondary` all unused in production.
- **`ApiClient.registerEndpointHeaders`** registry (`api_client.dart:59` + `header_interceptor.dart`): never called in `lib/`; only referenced in API docs markdown.
- **Deep-link telemetry surface** (`runtime/navigation/deep_link_telemetry.dart` + 6 `AnalyticsTracker` methods + 8 `AnalyticsParams` constants): all no-op telemetry that only logs; the app has exactly 2 external deep links. Keep one `trackPending`/`trackResumed`, drop the rest until analytics consumes them.
- **`AppLoadingOverlay`**: 10 config params; features pass only `isLoading` + `message`.
- **`RegisterComposer`/`BootstrapComposer`** (`di/composition/*.dart`): a `for` loop wrapping a `List` of already-ordered callbacks; call sites pass fixed literal lists. Pure ceremony.

---

## Feature Layer (`lib/features/`)

### 1. Profile slice use-case explosion

**Files:** `lib/features/account/subfeatures/profile/domain/usecase/*.dart` (14 files), `domain/repository/*.dart` (4 files), `data/repository/profile_draft_repository_impl.dart`, `di/account_profile_module.dart`

- 11 of 14 use cases are pure forwards with no added logic: `GetProfileDraftUseCase`, `SaveProfileDraftUseCase`, `ClearProfileDraftUseCase`, `GetProfileImageUrlUseCase`, `GetCachedProfileAvatarUseCase`, `RefreshProfileAvatarCacheUseCase`, `SaveProfileAvatarCacheUseCase`, `ClearProfileAvatarCacheUseCase`, `ClearAllProfileAvatarCachesUseCase`, `ListMeSessionsUseCase`, `RevokeMeSessionUseCase`.
- `GetProfileImageUrlUseCase` has **zero production callers** (DI registration + test only) — the avatar path calls `_remote.getProfileImageUrl()` directly via `ProfileAvatarRepositoryImpl.refreshAvatar`.
- `ClearAllProfileAvatarCachesUseCase` also has **zero production callers** — session-teardown goes through `ProfileAvatarCacheSessionListener` → `ProfileAvatarCacheLocalDataSource.clearAll()` directly.
- `ProfileDraftRepositoryImpl` is a pure wrapper over `ProfileDraftLocalDataSource` (no mapping, no error handling).

Suggested simplification: delete the two dead use cases; drop the draft repository layer (or let the cubit call the repository directly without the three draft use cases); call `ProfileAvatarRepository` directly from `ProfileImageCubit` for cache operations. Keep the two that compose real flows (`UploadProfileImageUseCase`, `ClearProfileImageUseCase`).

### 2. Account-deletion duplicated domain/data stack

**Files:** `domain/usecase/request_account_deletion_usecase.dart`, `cancel_account_deletion_usecase.dart`, `domain/entity/{request,cancel}_account_deletion_request_entity.dart`, `data/model/remote/{request,cancel}_account_deletion_request_model.dart`, `data/repository/account_deletion_repository_impl.dart:662–716`

Two use cases + two entities + two models + two byte-identical repository methods (same try/catch/`toEitherWithFallback`/`mapLeft(mapAccountAuthFailure)` body, differing only in endpoint and message) for two `POST` endpoints differing only by path. Both entities wrap a single always-null `idempotencyKey` — the datasource already does `request.idempotencyKey ?? IdempotencyKeyUtils.generate()`. ~3 classes + 3 DI registrations + ~600 lines of generated boilerplate for one behavior.

Suggested simplification: one use case + one entity + one model keyed by an action enum (`{request, cancel}`); generate the idempotency key inside the datasource.

### 3. `LogoutRemoteUseCase` — pure pass-through

**File:** `lib/features/auth/domain/usecase/logout_remote_usecase.dart`

`call(request) => _repository.logout(request)` — no logic; exists solely to sit between `LogoutFlowUseCase` and `AuthRepository`. Delete it and inject `AuthRepository` into `LogoutFlowUseCase` (also simplifies the `AuthRepository.logout(String refreshToken)` signature by dropping `LogoutRequestEntity`).

### 4. Speculative request-entity/option surface

- **Account deletion `idempotencyKey`**: always null in production; the entity exists only to carry a key the datasource generates anyway.
- **`ListMeSessionsRequestEntity.limit/cursor/sort`**: always provided by `MeSessionsCubit` (`limit: defaultLimit`, `sort: defaultSort`) — the "optional with defaults" surface is never exercised as optional.
- **8 freezed request entities** in auth mostly wrap 1–2 strings the repository immediately converts to a model.

### 5. Copy-pasted field-validation logic across cubits

**Files:** `change_password_cubit.dart` (46–136, 155–177), `password_reset_confirm_cubit.dart` (60–100, 168–198), `complete_profile_cubit.dart` (92–106, 165–172), `login_cubit.dart` (107–114), `register_cubit.dart` (77–84)

The same "validate → emit error → re-validate confirm → clear failure → reset failure status" block is copy-pasted 4+ times; `_validateConfirmNewPassword` and the new-vs-current check are identical in two cubits. Meanwhile `core/foundation/validation/find_first_validation_error_for_fields.dart` exists and is used for server errors — but login/register hand-roll the field-matching loop.

Suggested simplification: extract a small shared `PasswordFieldValidator`; use `findFirstValidationErrorForFields` in login/register.

### 6. Minor feature findings

- `RefreshCurrentUserAfterProfileImageMutation` sits in `domain/usecase/` as a non-class file with a `SessionFailure→AuthFailure` switch that duplicates what core session code already does; move the switch next to `account_auth_failure_mapper.dart`.
- `EmailVerificationState.isVerifying` is never read in `lib/`.
- `LogoutFailure` enum with one value `failed` + a dedicated localizer file — could be a const string.
- `MeSessionsCubit.refresh()` is an alias for `load()` with the same defaults.
- `MeSessionsState.revokeStatus` has `success`/`failure` variants never emitted (cubit only sets `submitting`/`idle`).

---

## Ranked Shortlist (most defensible first)

1. **Delete `DuplicationReportFilter` + allowlist JSONs** — ~700 lines + 3 hand-maintained configs whose only consumer is a human-readable summary; `fatalFound` is dead. Replace with one jscpd config + `--failOn`.
2. **Token-lint rules: extract shared scaffold** — kill 6–9 verbatim copies of `_PathConfig`/`_readGlobList`/`_ProjectRootFinder`/`_shorten`/`_isGeneratedDart`; ~60–70% of those files is copy-paste.
3. **`AppButton` param/constructor sprawl** — ~400 lines where every option except ~9 is unused in production; one constructor + `variant` removes ~300 lines and the dead `ButtonState` enum.
4. **Adaptive module's speculative surface** — `AdaptiveRegion`, `AdaptiveOverrides`, `AdaptiveSplitView`, `AdaptiveGrid`, `MinTapTarget`, `showAdaptiveSideSheet`, `foldables/`, unused spec aspects: ~12 files / ~1500 lines of unreachable code.
5. **CLI guardrail scanners** (`modal_entrypoints_check.dart`, `hardcoded_ui_colors_check.dart`) — delete in favor of the identical custom_lint rules; ~415 lines, and `verify` already runs custom_lint.
6. **Profile slice use-case explosion** — 11/14 pure forwards, 2 with zero production callers, 1 pure-wrapper repository.
7. **Account-deletion duplicated stack** — one use case + action enum replaces 2 use cases + 2 entities + 2 models + 2 identical repository methods.
8. **`ApiHelper`/`pagination_utils` dead surface** — `postPaginated`, `postFlexible`, `getList`, pagination utils, `ApiResponse` field helpers: ~halves the network helper surface.
9. **Zero-production widget groups** — `AppSearchExperience` (+3 support files), `AppFilterChipsBar`, `AppBottomNavBar`: delete until a screen needs them.
10. **Custom render-object shimmer** — replace with a ~40-line animated-gradient wrapper.
11. **`LogoutRemoteUseCase` pass-through** — delete; inject `AuthRepository` into `LogoutFlowUseCase`.
12. **Copy-pasted form validation across 4 cubits** — shared validator + existing core helper.
13. **Minor:** `fix` workflow (zero callers), `verify --skip-*` flags (test-only), triplicated env list, empty allowlist JSON, duplicated `.env` parsing, `registerEndpointHeaders`, deep-link telemetry surface, `AppTextField` sprawl, `RegisterComposer`/`BootstrapComposer` ceremony.

---

## Fairness Notes (checked and NOT flagged)

- **Clean-architecture layering itself** (data/domain/presentation, Freezed codegen, repository interfaces, `Either` use cases) is template-by-design — not flagged.
- **`runtime logs` / `runtime evidence`**: documented with worked examples and referenced by AGENTS.md risk policy — real, used features; only the duplicated process-forwarding plumbing is flagged.
- **`template_customization_engine.dart`** (~2,300 lines): genuinely complex problem (regex-rewriting Android Gradle, iOS pbxproj, ARB files with transactional rollback) — that complexity is load-bearing.
- **The lint rule *policies*** (hardcoded colors, spacing tokens, restricted imports, architecture boundaries): each is real and wired into `analysis_options.yaml` + CI — not flagged; only the duplicated *scaffolding* is.
- **Showcase screens / dev_tools**: intentionally demonstrate design-system surface for a template — some parameter sprawl is justified there; the flag is when *production* call sites use a small fraction of the API.
- `CodegenWorkflow.generate()` split from `run()`: the second caller (`template_workflow.dart:353`) genuinely wants "regenerate without freshness gate" — kept, with a possible rename for clarity.
