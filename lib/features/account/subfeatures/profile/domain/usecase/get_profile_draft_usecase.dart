import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_draft_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_draft_repository.dart';

class GetProfileDraftUseCase {
  GetProfileDraftUseCase(this._repository);

  final ProfileDraftRepository _repository;

  Future<ProfileDraftEntity?> call({required String userId}) =>
      _repository.getDraft(userId: userId);
}
