import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_account_deletion_request_entity.freezed.dart';

@freezed
abstract class RequestAccountDeletionRequestEntity
    with _$RequestAccountDeletionRequestEntity {
  const factory RequestAccountDeletionRequestEntity({String? idempotencyKey}) =
      _RequestAccountDeletionRequestEntity;
}
