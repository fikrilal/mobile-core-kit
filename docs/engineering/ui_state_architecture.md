# UI State Architecture — Flutter + BLoC/Cubit

Presentation-layer rules for this template. They follow the Bloc library:

- [Flutter Bloc Concepts](https://bloclibrary.dev/flutter-bloc-concepts/)
- [Bloc Concepts](https://bloclibrary.dev/bloc-concepts/)
- [Architecture](https://bloclibrary.dev/architecture/)
- [Flutter Login tutorial](https://bloclibrary.dev/tutorials/flutter-login/)

One state stream. Two widgets: **`BlocBuilder` paints. `BlocListener` does
one-shot work** (snackbar, dialog, navigation). Cubit/Bloc only `emit`s
state. Pages stay `StatelessWidget` unless they own Flutter objects
(`FocusNode`, `TextEditingController`, `ScrollController`).

## 1) Principles

- UI intent → Cubit/Bloc → use case or repository → **new state** → UI.
- One immutable state snapshot describes the screen (Freezed in this repo).
- `builder` is a **pure function**: return widgets from state. Do not snackbar,
  dialog, or navigate inside `builder`.
- One-shots run in `BlocListener`. `listener` fires **once per state change**,
  not for the initial state.
- Use `listenWhen` / `buildWhen` when you must not re-run the listener or
  rebuild on every field keystroke.
- Duplicate equal states are ignored (`==` / Freezed). Emit a **new instance**.
- No Cubit/Bloc listens to another Cubit/Bloc. Cross-slice: `BlocListener` in
  the page, or a shared repository stream
  ([architecture](https://bloclibrary.dev/architecture/)).

## 2) Layers

Presentation (pages, cubit/bloc, state) → domain (use cases, VOs, aggregates)
→ data (repositories, datasources). Cubit/Bloc may call a use case or, for a
pure pass-through, the repository.

`BlocProvider(create: …)` creates **and closes** the cubit. Dispatch the
initial load there, not in `build` and not in `addPostFrameCallback`.

```dart
GoRoute(
  path: ProductRoutes.detail,
  builder: (_, state) => BlocProvider(
    create: (_) => locator<ProductDetailCubit>()
      ..load(state.pathParameters['id']!),
    child: const ProductDetailPage(),
  ),
)
```

```dart
GoRoute(
  path: AuthRoutes.signIn,
  builder: (_, __) => BlocProvider(
    create: (_) => locator<LoginCubit>(),
    child: const SignInPage(),
  ),
)
```

## 3) Cubit vs Bloc

Official: start with **Cubit**; move to **Bloc** when you need event
traceability or event transformers
([Cubit vs Bloc](https://bloclibrary.dev/bloc-concepts/#cubit-vs-bloc)).

| | Cubit | Bloc |
|---|---|---|
| Intents | public methods (`load()`, `submit()`) returning `void` / `Future<void>` | `add(Event)` only |
| Use when | forms, detail GET, a few intents | search + pagination + filters, debounce / `droppable` / `restartable` |
| This template | Sign In, register, merchant wizard | add a Bloc when a list grows those needs |

Mixing Cubit and Bloc in one feature is fine.

## 4) State

Default: **one Freezed class + `status` enum**. Keep previous data on failure
so the page can still show what it had
([FAQ: handling errors](https://bloclibrary.dev/faqs/#handling-errors)).

```dart
enum ProductDetailStatus { initial, loading, success, failure }

@freezed
abstract class ProductDetailState with _$ProductDetailState {
  const factory ProductDetailState({
    @Default(ProductDetailStatus.initial) ProductDetailStatus status,
    Product? product,
    Object? failure,
  }) = _ProductDetailState;
}
```

Use a sealed **union** of states when fields are mutually exclusive (success
has `product`, failure has `message`, and you want an exhaustive `switch`).
Pick **one** model per slice. Do not mix enum-status and unions in the same
state type.

Forms add field strings, per-field errors, and a submit status:

```dart
enum LoginStatus { initial, submitting, success, failure }
```

Keep field errors on state so `BlocBuilder` can show them under inputs.
Keep the **operation** failure on state so `BlocListener` can snackbar.

## 5) Widgets

| Widget | Use |
|---|---|
| `BlocBuilder` | Rebuild UI from state (`AppAsyncStateView`, form fields). |
| `BlocListener` | Snackbar, dialog, `go` / `pop`, trigger another cubit. |
| `BlocConsumer` | Builder + listener in one widget when both are needed. |
| `BlocSelector` / `context.select` | Rebuild only when one field changes. |
| `context.read` | In **callbacks** (`onPressed`), never to read state in `build`. |

`BlocListener.listener` is `void`. It must not return widgets.

For several independent one-shots (snackbar **and** a dependent reload), use
`MultiBlocListener` with `listenWhen` on each
([todos overview](https://bloclibrary.dev/tutorials/flutter-todos/)).

Read-flow failures (GET): prefer an **inline** error + retry in `builder`.
Do not snackbar a failed product load unless product asks for it.

Mutation failures (POST login): snackbar in `listener`. Inline field errors
still come from state in `builder`.

## 6) Sample — GET / display (product detail)

No snackbar. Status drives the body. Retry is a button that calls `load` again.

```dart
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(this._getProduct) : super(const ProductDetailState());

  final GetProductUseCase _getProduct;

  Future<void> load(String id) async {
    emit(state.copyWith(status: ProductDetailStatus.loading, failure: null));
    final result = await _getProduct(id);
    result.match(
      (failure) => emit(
        state.copyWith(status: ProductDetailStatus.failure, failure: failure),
      ),
      (product) => emit(
        state.copyWith(status: ProductDetailStatus.success, product: product),
      ),
    );
  }
}
```

```dart
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          return AppAsyncStateView<Object>(
            status: switch (state.status) {
              ProductDetailStatus.initial ||
              ProductDetailStatus.loading => AppAsyncStatus.loading,
              ProductDetailStatus.success => AppAsyncStatus.success,
              ProductDetailStatus.failure => AppAsyncStatus.failure,
            },
            failure: state.failure,
            loadingBuilder: (_) => const ProductDetailSkeleton(),
            successBuilder: (_) => ProductDetailBody(product: state.product!),
            onRetry: () => context.read<ProductDetailCubit>().load(/* id */),
            retryLabel: 'Retry',
          );
        },
      ),
    );
  }
}
```

In-repo GET-shaped screens (list/detail, inline load/error): sessions and
account profile. `AppAsyncStateView` is render-only — no navigation inside
its builders.

## 7) Sample — mutation + one-shot (login)

Submit writes `status` + `failure` on **state**. The page listens for the
**transition** into failure and shows a snackbar. Same cubit, no second
stream.

```dart
class LoginCubit extends Cubit<LoginState> {
  // ...
  Future<void> submit() async {
    emit(state.copyWith(status: LoginStatus.submitting, failure: null));
    final result = await _loginUser(LoginInput(...));
    result.match(
      (failure) => emit(
        state.copyWith(status: LoginStatus.failure, failure: failure),
      ),
      (user) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: LoginStatus.initial, failure: null));
  }
}
```

```dart
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.authSignIn)),
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) =>
            current.status == LoginStatus.failure &&
            current.failure != null &&
            (previous.status != LoginStatus.failure ||
                previous.failure != current.failure),
        listener: (context, state) {
          AppSnackBar.showError(
            context,
            message: messageForAuthFailure(state.failure!, context.l10n),
          );
        },
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            return Column(
              children: [
                AppTextField(
                  errorText: state.emailError == null
                      ? null
                      : messageForAuthFieldError(state.emailError!, context.l10n),
                  onChanged: context.read<LoginCubit>().emailChanged,
                ),
                AppButton.primary(
                  isLoading: state.isSubmittingEmailPassword,
                  isDisabled: !state.canSubmit,
                  onPressed: state.canSubmit
                      ? () => context.read<LoginCubit>().submit()
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

`listenWhen` is how you avoid a second snackbar on an unrelated rebuild.
Typing already sets `status` back to `initial`, so the next submit is a new
`failure` transition.

Working copy of this shape: `lib/features/auth/subfeatures/sign_in/presentation/pages/sign_in_page_ofc.dart`.

Need snackbar **and** `pop()` after success? One listener:

```dart
listener: (context, state) {
  if (state.status == LoginStatus.failure && state.failure != null) {
    AppSnackBar.showError(...);
  }
  if (state.status == LoginStatus.success) {
    context.pop();
  }
}
```

Or two `BlocListener`s with different `listenWhen`.

## 8) Dependent loads

When cubit B must run after cubit A changes, listen in the **page**:

```dart
BlocListener<ProductDetailCubit, ProductDetailState>(
  listenWhen: (p, c) => p.product?.id != c.product?.id && c.product != null,
  listener: (context, state) {
    context.read<RelatedItemsCubit>().load(state.product!.id);
  },
  child: ...,
)
```

Do not subscribe one cubit to another cubit’s stream.

## 9) Concurrency (Bloc)

For search/pagination, use `bloc_concurrency` transformers
([official EventTransformer](https://bloclibrary.dev/bloc-concepts/#advanced-event-transformations)):

- Next page: `droppable()`
- Search/filter: `restartable()`, debounce input before `add`

Cubit: a boolean guard (`isLoadingMore`) is enough.

## 10) Do

- Paint with `BlocBuilder`. Fire snackbar/nav/dialog with `BlocListener`.
- Keep pages `StatelessWidget` unless they own `FocusNode` / controllers.
- Dispatch `load` / `Started` in `BlocProvider.create`.
- Put field errors on state; put operation `failure` on state; listen for
  **status transitions**.
- Use `listenWhen` so a snackbar runs once per failed submit.
- `context.read` in `onPressed` only.
- Close nothing extra: `BlocProvider` closes the cubit; `BlocListener`
  unsubscribes itself.
- `bloc_test`: expect `submitting` then `failure` (or `success`). Widget
  tests pump the listener and assert a snackbar if needed.

## 11) Don't

- Don’t snackbar, dialog, or `go`/`pop` inside `builder` or `AppAsyncStateView`.
- Don’t add a second command stream on the cubit (`StreamController`, sealed
  `Effect`, page `StreamSubscription`).
- Don’t `addPostFrameCallback` to start a load.
- Don’t `context.read<Cubit>().state` inside `build` to render (it won’t
  rebuild).
- Don’t make two cubits listen to each other.
- Don’t `emit(state)` (same instance). Don’t mutate Freezed state in place.
- Don’t expose non-`void` methods on a Cubit besides `state` getters.
- Don’t put `Navigator` / `BuildContext` in the cubit.
- Don’t use `setState` for form fields or submit status (that’s cubit state).
  Local `setState` is only for widget objects (`FocusNode`, `PopScope.canPop`).

## 12) Checklists

**GET / detail / list**

- [ ] State: `status`, data, `failure`.
- [ ] `load()` / `Started` from the route `create`.
- [ ] One `BlocBuilder` (or `AppAsyncStateView`). Failure is inline + retry.
- [ ] No `BlocListener` unless a parent must react (dependent load).

**Form / login / submit**

- [ ] State: fields, field errors, `status` (`initial` / `submitting` /
      `success` / `failure`), operation `failure`.
- [ ] `BlocListener` + `listenWhen` for snackbar / pop.
- [ ] `BlocBuilder` for inputs, button loading, `canSubmit`.
- [ ] Disable the button while submitting.
- [ ] `bloc_test` asserts state sequence; no custom effect list.

**Wizard / back intercept**

- [ ] Form still cubit state.
- [ ] Dialogs and snackbars: `BlocListener`.
- [ ] `PopScope` is Flutter routing, not cubit state. Prefer deriving
      `canPop` from cubit (`!isDirty`) so you can `pop()` from the listener
      after the cubit clears dirty.

## 13) Testing

```dart
blocTest<LoginCubit, LoginState>(
  'emits submitting then failure',
  build: () {
    when(() => loginUser(any())).thenAnswer(
      (_) async => const Left(AuthFailure.network()),
    );
    return LoginCubit(...);
  },
  act: (cubit) async {
    cubit.emailChanged('a@b.com');
    cubit.passwordChanged('longenough1');
    await cubit.submit();
  },
  expect: () => [
    isA<LoginState>(),
    isA<LoginState>().having((s) => s.status, 'status', LoginStatus.submitting),
    isA<LoginState>().having((s) => s.status, 'status', LoginStatus.failure),
  ],
);
```

Widget test the listener by pumping `SignInPage` (or `SignInPageOfc`) with a
cubit that emits `failure` and expecting `AppSnackBar`.

## 14) In-repo references

- Listener-shaped login: `lib/features/auth/subfeatures/sign_in/presentation/pages/sign_in_page_ofc.dart`
- Login state/cubit: `lib/features/auth/subfeatures/sign_in/presentation/cubit/login/`
- GET-shaped list: `lib/features/account/subfeatures/security/presentation/pages/me_sessions_page.dart` (load/error body; revoke still uses a listener)
- Merchant route load: `lib/navigation/merchant_onboarding/merchant_onboarding_routes_list.dart`
- Validation (VOs, aggregates): `docs/engineering/validation_architecture.md`
- Tokens / fields: `lib/core/design_system/`
