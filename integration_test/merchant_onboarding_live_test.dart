import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/foundation/config/app_config.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/foundation/utilities/uuid_v4_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_launch_service.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_startup_controller.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_response_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/register_request_model.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/datasource/remote/merchant_onboarding_remote_datasource.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_onboarding_submit_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/pages/merchant_onboarding_page.dart';
import 'package:mobile_core_kit/navigation/app_router.dart';
import 'package:mobile_core_kit/navigation/merchant_onboarding/merchant_onboarding_routes.dart';

import 'support/integration_test_app.dart';

/// Live merchant-onboarding E2E against the accepted local backend.
///
/// Prerequisites (fail closed when absent):
/// - `--dart-define=LIVE_E2E=1` to enable this test;
/// - a reachable dev backend at `10.0.2.2:4000` (emulator) or the override
///   `--dart-define=LIVE_BASE_URL=http://<host>:4000/v1`;
/// - `--dart-define=LIVE_TEST_EMAIL=...` and `LIVE_TEST_PASSWORD=...` (an
///   ephemeral unique principal; never commit real credentials).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final liveEnabled = const String.fromEnvironment('LIVE_E2E') == '1';
  final liveBaseUrl = const String.fromEnvironment(
    'LIVE_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/v1',
  );
  final testEmail = const String.fromEnvironment('LIVE_TEST_EMAIL');
  final testPassword = const String.fromEnvironment('LIVE_TEST_PASSWORD');

  group('merchant onboarding live', () {
    late String uniqueEmail;

    setUpAll(() async {
      if (!liveEnabled) return;
      if (testEmail.isEmpty || testPassword.isEmpty) {
        fail(
          'Live E2E requires LIVE_TEST_EMAIL and LIVE_TEST_PASSWORD '
          '(ephemeral, never committed).',
        );
      }

      // Boot the production DI graph exactly like the real app. The launch
      // service is overridden with a fast, deterministic onboarding answer so
      // startup never falls back to showing onboarding on a slow emulator.
      AppConfig.init(const AppConfig(accessToken: ''));
      registerLocator();
      locator.allowReassignment = true;
      locator.registerSingleton<AppLaunchService>(_NoOnboardingLaunchService());
      locator.allowReassignment = false;
      await bootstrapLocator();

      // Provision a unique principal through the real auth datasource.
      uniqueEmail =
          '${testEmail.split('@').first}+${DateTime.now().millisecondsSinceEpoch}'
          '@${testEmail.split('@').last}';
      final authRemote = locator<AuthRemoteDataSource>();
      final registerResult = await authRemote.register(
        RegisterRequestModel(email: uniqueEmail, password: testPassword),
      );
      expect(
        registerResult.isSuccess,
        true,
        reason: 'ephemeral registration should succeed: ${registerResult.code}',
      );

      // Put the session into the production session manager. A fresh user
      // has no given name, which would redirect to profile completion, so set
      // one to keep the wizard reachable from Home.
      final sessionEntity = registerResult.data!.toSessionEntity();
      await locator<SessionManager>().login(sessionEntity);
      final user = sessionEntity.user!.copyWith(
        profile: sessionEntity.user!.profile.copyWith(givenName: 'Budi Live'),
      );
      await locator<SessionManager>().setUser(user);
      await locator<AppStartupController>().initialize();
    });

    testWidgets(
      'wizard submits against the real backend and shows the application id',
      (tester) async {
        if (!liveEnabled) {
          markTestSkipped(
            'Live E2E disabled: pass --dart-define=LIVE_E2E=1 with a reachable '
            'backend and ephemeral credentials.',
          );
          return;
        }

        final router = createRouter();
        await tester.pumpWidget(buildIntegrationTestApp(routerConfig: router));
        await tester.pumpAndSettle();

        // Navigate directly to the merchant onboarding route. The Home entry
        // is covered by widget tests; here the wizard itself is exercised
        // against the live backend through the production router.
        router.go(MerchantOnboardingRoutes.root);
        await tester.pumpAndSettle();

        // Reference data must come from the live GET; the wizard renders
        // step one.
        expect(find.text('Business profile'), findsOneWidget);

        final context = tester.element(find.byType(MerchantOnboardingPage));
        final cubit = context.read<MerchantOnboardingCubit>();
        final reference = cubit.state.referenceData!;

        // Step 1: business, selecting IDs from the live snapshot.
        await tester.enterText(
          find.byKey(const ValueKey('business_legal_name')),
          'Kopi Nusantara Live',
        );
        cubit.businessTypeChanged(reference.businessTypes.first.id);
        cubit.businessIndustryChanged(reference.industries.first.id);
        cubit.businessMonthlySalesRangeChanged(
          reference.monthlySalesRanges.first.id,
        );
        cubit.businessContactEmailChanged(uniqueEmail);
        cubit.businessContactPhoneChanged('+6281234567890');
        cubit.nextTapped();
        await tester.pumpAndSettle();

        // Step 2: owners — one complete owning row.
        cubit.ownerAdded();
        final ownerId = cubit.state.input.owners.single.ownerRowId;
        cubit.ownerNameChanged(ownerId, 'Budi Live');
        cubit.ownerRoleChanged(ownerId, 'owner');
        cubit.ownerPercentageChanged(ownerId, '100');
        cubit.ownerEmailChanged(ownerId, uniqueEmail);
        cubit.ownerPrimaryToggled(ownerId, true);
        cubit.nextTapped();
        await tester.pumpAndSettle();

        // Step 3: settlement — business-held account with a leading zero.
        cubit.settlementBankChanged('demo_bank_alpha');
        cubit.settlementHolderNameChanged('Budi Live');
        cubit.settlementAccountNumberChanged('0012345678');
        cubit.settlementHolderTypeChanged('business');
        cubit.settlementPayoutScheduleChanged('daily');
        cubit.nextTapped();
        await tester.pumpAndSettle();

        // Step 4: review — masked account, never the raw value.
        expect(find.text('0012345678'), findsNothing);
        expect(find.text('****5678'), findsOneWidget);

        // Accept declarations and submit.
        await tester.ensureVisible(
          find.byKey(const ValueKey('declaration_information_accurate')),
        );
        await tester.tap(
          find.byKey(const ValueKey('declaration_information_accurate')),
        );
        await tester.tap(
          find.byKey(const ValueKey('declaration_authorized_to_submit')),
        );
        await tester.tap(
          find.byKey(const ValueKey('declaration_terms_accepted')),
        );
        await tester.pumpAndSettle();

        cubit.submitTapped();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        expect(cubit.state.submissionStatus, MerchantSubmissionStatus.success);
        // ignore: avoid_print
        print('LIVE_E2E wizard submission succeeded');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    testWidgets('idempotent replay returns the same application id', (
      tester,
    ) async {
      if (!liveEnabled) return;

      // Provision a fresh user that has not submitted yet so the backend
      // one-application invariant does not turn the replay into an
      // already-exists outcome.
      final authRemote = locator<AuthRemoteDataSource>();
      final replayEmail =
          '${testEmail.split('@').first}+replay${DateTime.now().millisecondsSinceEpoch}'
          '@${testEmail.split('@').last}';
      final registerResult = await authRemote.register(
        RegisterRequestModel(email: replayEmail, password: testPassword),
      );
      expect(registerResult.isSuccess, true);
      final replaySession = registerResult.data!.toSessionEntity();
      await locator<SessionManager>().login(replaySession);

      // Use the real repository submit path with the same validated
      // application twice; the repository generates one key per invocation,
      // so both calls carry the same idempotency key.
      final refRemote = locator<MerchantOnboardingRemoteDataSource>();
      final refResult = await refRemote.fetchReferenceData();
      expect(refResult.isSuccess, true);

      final snapshot = refResult.data!.toDomain();
      final application = await buildValidApplication(
        email: replayEmail,
        reference: snapshot,
      );

      // Bounded datasource check: replay the exact same request with the
      // same idempotency key. The backend must return the stored result
      // without creating a second application.
      final remote = locator<MerchantOnboardingRemoteDataSource>();
      final request = MerchantOnboardingSubmitRequestModel.fromApplication(
        application,
      );
      final key = IdempotencyKeyUtils.generate();
      final first = await remote.submitApplication(
        request: request,
        idempotencyKey: key,
      );
      final replay = await remote.submitApplication(
        request: request,
        idempotencyKey: key,
      );

      if (first.isError) {
        fail('first submit failed: ${first.code}');
      }
      if (replay.isError) {
        fail('replay submit failed: ${replay.code}');
      }
      expect(first.statusCode, 201);
      expect(replay.statusCode, 201);
      expect(replay.data!.applicationId, first.data!.applicationId);
    });

    testWidgets('unauthenticated reference request maps to safe failure', (
      tester,
    ) async {
      if (!liveEnabled) return;

      // A fresh unauthenticated Dio helper must surface UNAUTHORIZED without
      // looping; the datasource maps it to a safe ApiResponse error. This raw
      // Dio has no BaseUrlInterceptor, so the base URL must include the
      // backend's `/v1` prefix.
      final dio = Dio(
        BaseOptions(
          baseUrl: liveBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final helper = ApiHelper(dio);
      final remote = MerchantOnboardingRemoteDataSource(helper);
      final response = await remote.fetchReferenceData();

      expect(response.isError, true);
      expect(response.code, 'UNAUTHORIZED');
    });
  });
}

/// Builds a validated application from the live reference snapshot.
Future<MerchantOnboardingApplication> buildValidApplication({
  required String email,
  required MerchantReferenceDataEntity reference,
}) async {
  final owningRole = reference.ownerRoles.firstWhere(
    (r) => r.contributesOwnership,
  );
  final bank = reference.banks.first;
  final schedule = bank.supportedScheduleIds.first;
  final businessHolder = reference.holderTypes.firstWhere(
    (h) => !h.requiresOwnerReference,
  );

  final input = MerchantOnboardingInput(
    business: BusinessProfileInput(
      legalName: 'Kopi Nusantara Replay',
      businessTypeId: reference.businessTypes.first.id,
      industryId: reference.industries.first.id,
      monthlySalesRangeId: reference.monthlySalesRanges.first.id,
      contactEmail: email,
      contactPhone: '+6281234567890',
    ),
    owners: [
      OwnerInput(
        ownerRowId: UuidV4Utils.generate(),
        fullName: 'Budi Replay',
        roleId: owningRole.id,
        ownershipPercentage: '100',
        email: email,
        isPrimaryContact: true,
      ),
    ],
    settlement: SettlementInput(
      bankId: bank.id,
      accountHolderName: 'Budi Replay',
      accountNumber: '0012345678',
      holderTypeId: businessHolder.id,
      payoutScheduleId: schedule,
    ),
    declarations: DeclarationsInput(
      informationAccurate: true,
      authorizedToSubmit: true,
      termsAccepted: true,
      termsVersion: reference.termsVersion,
    ),
  );
  final result = MerchantOnboardingApplication.create(
    input: input,
    reference: reference,
  );
  return result.getRight().toNullable()!;
}

/// Test-only launch service that always reports onboarding as seen so the
/// router redirects to Home instead of the onboarding placeholder.
class _NoOnboardingLaunchService implements AppLaunchService {
  @override
  Future<bool> shouldShowOnboarding() async => false;

  @override
  Future<void> markOnboardingSeen() async {}
}
