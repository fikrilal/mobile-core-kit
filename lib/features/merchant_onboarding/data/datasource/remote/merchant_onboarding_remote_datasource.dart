import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/merchant_onboarding_endpoint.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_onboarding_submit_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_reference_data_models.dart';

class MerchantOnboardingRemoteDataSource {
  MerchantOnboardingRemoteDataSource(this._apiHelper);

  final String _tag = 'MerchantOnboardingRemoteDataSource';
  final ApiHelper _apiHelper;

  Future<ApiResponse<MerchantReferenceDataModel>> fetchReferenceData() async {
    Log.info('Fetching merchant onboarding reference data', name: _tag);

    return _apiHelper.getOne<MerchantReferenceDataModel>(
      MerchantOnboardingEndpoint.referenceData,
      host: ApiHost.core,
      requiresAuth: true,
      throwOnError: false,
      parser: MerchantReferenceDataModel.fromJson,
    );
  }

  Future<ApiResponse<MerchantSubmitResultModel>> submitApplication({
    required MerchantOnboardingSubmitRequestModel request,
    String? idempotencyKey,
  }) async {
    Log.info('Submitting merchant onboarding application', name: _tag);

    return _apiHelper.post<MerchantSubmitResultModel>(
      MerchantOnboardingEndpoint.applications,
      host: ApiHost.core,
      requiresAuth: true,
      throwOnError: false,
      headers: IdempotencyKeyUtils.headers(idempotencyKey),
      data: request.toJson(),
      parser: MerchantSubmitResultModel.fromJson,
    );
  }
}
