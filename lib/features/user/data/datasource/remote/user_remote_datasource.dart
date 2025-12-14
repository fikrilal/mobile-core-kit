import '../../../../../core/configs/api_host.dart';
import '../../../../../core/network/api/api_helper.dart';
import '../../../../../core/network/api/api_response.dart';
import '../../../../../core/network/api/api_parsers.dart';
import '../../../../../core/network/endpoints/user_endpoint.dart';
import '../../../../../core/utilities/log_utils.dart';
import '../../model/remote/user_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._apiHelper);
  final String _tag = 'UserRemoteDataSource';

  final ApiHelper _apiHelper;

  Future<ApiResponse<UserModel>> getMe() async {
    Log.info('Fetching current user', name: _tag);

    final response = await _apiHelper.getOne<UserModel>(
      UserEndpoint.me,
      host: ApiHost.profile,
      parser: ApiParsers.dataEnvelope(UserModel.fromJson),
    );

    Log.info('Fetched current user successfully', name: _tag);
    return response;
  }
}
