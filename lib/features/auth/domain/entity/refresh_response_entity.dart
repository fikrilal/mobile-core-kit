import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_response_entity.freezed.dart';

@freezed
abstract class RefreshResponseEntity with _$RefreshResponseEntity {
  const factory RefreshResponseEntity({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) = _RefreshResponseEntity;
}
