import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/datasource/remote/merchant_onboarding_remote_datasource.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/error/merchant_onboarding_failure_mapper.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_onboarding_submit_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';

class MerchantOnboardingRepositoryImpl implements MerchantOnboardingRepository {
  MerchantOnboardingRepositoryImpl(this._remote);

  final MerchantOnboardingRemoteDataSource _remote;

  @override
  Future<Either<MerchantOnboardingFailure, MerchantReferenceDataEntity>>
  loadReferenceData() async {
    try {
      final response = await _remote.fetchReferenceData();
      return response
          .toEitherWithFallback('Failed to load reference data.')
          .mapLeft(mapMerchantReferenceFailure)
          .map((model) => model.toDomain());
    } catch (e, st) {
      Log.error(
        'Load reference data unexpected error',
        e,
        st,
        true,
        'MerchantOnboardingRepository',
      );
      return left(const MerchantUnexpectedFailure());
    }
  }

  @override
  Future<Either<MerchantOnboardingFailure, MerchantApplicationReceipt>>
  submitApplication(MerchantOnboardingApplication application) async {
    try {
      final request = MerchantOnboardingSubmitRequestModel.fromApplication(
        application,
      );
      final response = await _remote.submitApplication(request: request);
      return response
          .toEitherWithFallback('Failed to submit application.')
          .mapLeft(mapMerchantSubmitFailure)
          .map(
            (model) =>
                MerchantApplicationReceipt(applicationId: model.applicationId),
          );
    } catch (e, st) {
      Log.error(
        'Submit application unexpected error',
        e,
        st,
        true,
        'MerchantOnboardingRepository',
      );
      return left(const MerchantUnexpectedFailure());
    }
  }
}
