import 'package:mobile_core_kit/features/account/subfeatures/profile/data/datasource/local/profile_draft_local_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_draft_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_draft_repository.dart';

class ProfileDraftRepositoryImpl implements ProfileDraftRepository {
  ProfileDraftRepositoryImpl(this._local);

  final ProfileDraftLocalDataSource _local;

  @override
  Future<ProfileDraftEntity?> getDraft({required String userId}) =>
      _local.getDraft(userId: userId);

  @override
  Future<void> saveDraft({
    required String userId,
    required ProfileDraftEntity draft,
  }) => _local.saveDraft(userId: userId, draft: draft);

  @override
  Future<void> clearDraft({required String userId}) =>
      _local.clearDraft(userId: userId);
}
