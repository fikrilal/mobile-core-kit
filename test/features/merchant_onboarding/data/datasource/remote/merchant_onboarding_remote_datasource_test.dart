import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/datasource/remote/merchant_onboarding_remote_datasource.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_onboarding_submit_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_reference_data_models.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiHelper extends Mock implements ApiHelper {}

void main() {
  setUpAll(() {
    registerFallbackValue(ApiHost.core);
  });

  late _MockApiHelper apiHelper;
  late MerchantOnboardingRemoteDataSource datasource;

  setUp(() {
    apiHelper = _MockApiHelper();
    datasource = MerchantOnboardingRemoteDataSource(apiHelper);
  });

  test(
    'fetchReferenceData uses core host, auth, and the reference parser',
    () async {
      const model = MerchantReferenceDataModel(
        businessTypes: [],
        industries: [],
        monthlySalesRanges: [],
        ownerRoles: [],
        banks: [],
        accountHolderTypes: [],
        payoutSchedules: [],
        termsVersion: '2026-08-30',
      );
      when(
        () => apiHelper.getOne<MerchantReferenceDataModel>(
          any(),
          parser: any(named: 'parser'),
          host: any(named: 'host'),
          requiresAuth: any(named: 'requiresAuth'),
          throwOnError: any(named: 'throwOnError'),
        ),
      ).thenAnswer((_) async => ApiResponse.success(data: model));

      final response = await datasource.fetchReferenceData();

      expect(response.isSuccess, true);
      verify(
        () => apiHelper.getOne<MerchantReferenceDataModel>(
          '/merchant-onboarding/reference-data',
          parser: any(named: 'parser'),
          host: any(named: 'host'),
          requiresAuth: true,
          throwOnError: false,
        ),
      ).called(1);
    },
  );

  test(
    'submitApplication posts with one idempotency header and core host',
    () async {
      const request = MerchantOnboardingSubmitRequestModel(
        business: MerchantBusinessInputModel(
          legalName: 'Kopi Nusantara',
          businessTypeId: 'sole_proprietorship',
          industryId: 'retail',
          monthlySalesRangeId: '10m_to_50m_idr',
          contactEmail: 'contact@kopinusantara.id',
          contactPhone: '+6281234567890',
        ),
        owners: [],
        settlement: MerchantSettlementInputModel(
          bankId: 'demo_bank_alpha',
          accountHolderName: 'Budi Santoso',
          accountNumber: '0012345678',
          holderTypeId: 'business',
          payoutScheduleId: 'daily',
        ),
        declarations: MerchantDeclarationsInputModel(
          informationAccurate: true,
          authorizedToSubmit: true,
          termsAccepted: true,
          termsVersion: '2026-08-30',
        ),
      );
      const result = MerchantSubmitResultModel(
        applicationId: 'app-1',
        submittedAt: '2026-08-31T00:00:00.000Z',
      );
      when(
        () => apiHelper.post<MerchantSubmitResultModel>(
          any(),
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          host: any(named: 'host'),
          requiresAuth: any(named: 'requiresAuth'),
          throwOnError: any(named: 'throwOnError'),
          parser: any(named: 'parser'),
        ),
      ).thenAnswer((_) async => ApiResponse.success(data: result));

      final response = await datasource.submitApplication(
        request: request,
        idempotencyKey: 'fixed-key',
      );

      expect(response.isSuccess, true);
      verify(
        () => apiHelper.post<MerchantSubmitResultModel>(
          '/merchant-onboarding/applications',
          data: any(named: 'data'),
          headers: any(
            named: 'headers',
            that: containsPair('Idempotency-Key', 'fixed-key'),
          ),
          host: any(named: 'host'),
          requiresAuth: true,
          throwOnError: false,
          parser: any(named: 'parser'),
        ),
      ).called(1);
    },
  );
}
