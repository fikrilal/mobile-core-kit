import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/session/auth_to_session_failure_mapper.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/domain/usecase/get_current_user_usecase.dart';

class AccountCurrentUserFetcherAdapter implements CurrentUserFetcher {
  AccountCurrentUserFetcherAdapter(this._getCurrentUser);

  final GetCurrentUserUseCase _getCurrentUser;

  @override
  Future<Either<SessionFailure, UserEntity>> fetch() async {
    final result = await _getCurrentUser();
    return result.mapLeft(mapAuthFailureToSessionFailure);
  }
}
