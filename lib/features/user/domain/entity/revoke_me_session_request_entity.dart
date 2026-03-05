import 'package:freezed_annotation/freezed_annotation.dart';

part 'revoke_me_session_request_entity.freezed.dart';

@freezed
abstract class RevokeMeSessionRequestEntity
    with _$RevokeMeSessionRequestEntity {
  const factory RevokeMeSessionRequestEntity({required String sessionId}) =
      _RevokeMeSessionRequestEntity;
}
