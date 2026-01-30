import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_deletion_entity.freezed.dart';

@freezed
abstract class AccountDeletionEntity with _$AccountDeletionEntity {
  const factory AccountDeletionEntity({
    required String requestedAt,
    required String scheduledFor,
  }) = _AccountDeletionEntity;
}
