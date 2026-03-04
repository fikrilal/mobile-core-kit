import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/user/domain/entity/cancel_account_deletion_request_entity.dart';

part 'cancel_account_deletion_request_model.freezed.dart';

/// Request metadata for `POST /v1/me/account-deletion/cancel`.
///
/// The backend contract has no JSON body for this endpoint.
/// This model keeps request-shaping concerns in the data layer.
@freezed
abstract class CancelAccountDeletionRequestModel
    with _$CancelAccountDeletionRequestModel {
  const factory CancelAccountDeletionRequestModel({String? idempotencyKey}) =
      _CancelAccountDeletionRequestModel;
}

extension CancelAccountDeletionRequestEntityX
    on CancelAccountDeletionRequestEntity {
  CancelAccountDeletionRequestModel toModel() {
    return CancelAccountDeletionRequestModel(idempotencyKey: idempotencyKey);
  }
}
