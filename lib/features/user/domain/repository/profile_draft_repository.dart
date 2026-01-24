import 'package:mobile_core_kit/features/user/domain/entity/profile_draft_entity.dart';

abstract class ProfileDraftRepository {
  Future<ProfileDraftEntity?> getDraft({required String userId});

  Future<void> saveDraft({
    required String userId,
    required ProfileDraftEntity draft,
  });

  Future<void> clearDraft({required String userId});
}
