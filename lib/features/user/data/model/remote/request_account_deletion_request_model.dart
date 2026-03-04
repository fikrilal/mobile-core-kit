import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/user/domain/entity/request_account_deletion_request_entity.dart';

part 'request_account_deletion_request_model.freezed.dart';

/// Request metadata for `POST /v1/me/account-deletion/request`.
///
/// The backend contract has no JSON body for this endpoint.
/// This model keeps request-shaping concerns in the data layer.
@freezed
abstract class RequestAccountDeletionRequestModel
    with _$RequestAccountDeletionRequestModel {
  const factory RequestAccountDeletionRequestModel({
    String? idempotencyKey,
  }) = _RequestAccountDeletionRequestModel;
}

extension RequestAccountDeletionRequestEntityX
    on RequestAccountDeletionRequestEntity {
  RequestAccountDeletionRequestModel toModel() {
    return RequestAccountDeletionRequestModel(idempotencyKey: idempotencyKey);
  }
}
