import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_draft_repository.dart';

class ClearProfileDraftUseCase {
  ClearProfileDraftUseCase(this._repository);

  final ProfileDraftRepository _repository;

  Future<void> call({required String userId}) =>
      _repository.clearDraft(userId: userId);
}
