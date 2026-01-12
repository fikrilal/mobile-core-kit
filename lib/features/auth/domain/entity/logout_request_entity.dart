import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_request_entity.freezed.dart';

@freezed
abstract class LogoutRequestEntity with _$LogoutRequestEntity {
  const factory LogoutRequestEntity({
    required String refreshToken,
  }) = _LogoutRequestEntity;
}

