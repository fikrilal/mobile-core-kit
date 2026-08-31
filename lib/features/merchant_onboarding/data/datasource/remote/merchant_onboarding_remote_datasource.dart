import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/merchant_onboarding_endpoint.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_onboarding_submit_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_reference_data_models.dart';

/// Authenticated remote datasource for the merchant-onboarding endpoints.
class MerchantOnboardingRemoteDataSource {
  MerchantOnboardingRemoteDataSource(this._apiHelper);

  final String _tag = 'MerchantOnboardingRemoteDataSource';
  final ApiHelper _apiHelper;

  Future<ApiResponse<MerchantReferenceDataDto>> fetchReferenceData() async {
    Log.info('Fetching merchant onboarding reference data', name: _tag);

    return _apiHelper.getOne<MerchantReferenceDataDto>(
      MerchantOnboardingEndpoint.referenceData,
      host: ApiHost.core,
      requiresAuth: true,
      throwOnError: false,
      parser: MerchantReferenceDataDto.fromJson,
    );
  }

  /// Submits a validated application. One non-empty idempotency key is
  /// generated per invocation; Dio automatic retries reuse the same request
  /// headers, so an ambiguous retry cannot create a second application.
  Future<ApiResponse<MerchantSubmitResultDto>> submitApplication({
    required MerchantOnboardingSubmitRequestDto request,
    String? idempotencyKey,
  }) async {
    Log.info('Submitting merchant onboarding application', name: _tag);

    return _apiHelper.post<MerchantSubmitResultDto>(
      MerchantOnboardingEndpoint.applications,
      host: ApiHost.core,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key': idempotencyKey ?? IdempotencyKeyUtils.generate(),
      },
      data: request.toJson(),
      parser: MerchantSubmitResultDto.fromJson,
    );
  }
}
