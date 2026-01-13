import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_request_entity.freezed.dart';

@freezed
abstract class RefreshRequestEntity with _$RefreshRequestEntity {
  const factory RefreshRequestEntity({required String refreshToken}) =
      _RefreshRequestEntity;
}
