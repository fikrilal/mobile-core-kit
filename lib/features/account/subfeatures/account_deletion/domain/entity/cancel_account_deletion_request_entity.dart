import 'package:freezed_annotation/freezed_annotation.dart';

part 'cancel_account_deletion_request_entity.freezed.dart';

@freezed
abstract class CancelAccountDeletionRequestEntity
    with _$CancelAccountDeletionRequestEntity {
  const factory CancelAccountDeletionRequestEntity({String? idempotencyKey}) =
      _CancelAccountDeletionRequestEntity;
}
