import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/revoke_me_session_request_entity.dart';

part 'revoke_me_session_request_model.freezed.dart';

/// Request metadata for `POST /v1/me/sessions/{sessionId}/revoke`.
@freezed
abstract class RevokeMeSessionRequestModel with _$RevokeMeSessionRequestModel {
  const factory RevokeMeSessionRequestModel({required String sessionId}) =
      _RevokeMeSessionRequestModel;
}

extension RevokeMeSessionRequestEntityX on RevokeMeSessionRequestEntity {
  RevokeMeSessionRequestModel toModel() {
    return RevokeMeSessionRequestModel(sessionId: sessionId);
  }
}
