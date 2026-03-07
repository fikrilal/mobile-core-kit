import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_draft_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_draft_repository.dart';

class SaveProfileDraftUseCase {
  SaveProfileDraftUseCase(this._repository);

  final ProfileDraftRepository _repository;

  Future<void> call({
    required String userId,
    required ProfileDraftEntity draft,
  }) => _repository.saveDraft(userId: userId, draft: draft);
}
