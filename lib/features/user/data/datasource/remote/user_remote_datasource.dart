import 'package:mobile_core_kit/core/configs/api_host.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/core/utilities/log_utils.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/user_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._apiHelper);
  final String _tag = 'UserRemoteDataSource';

  final ApiHelper _apiHelper;

  Future<ApiResponse<UserModel>> getMe() async {
    Log.info('Fetching current user', name: _tag);

    final response = await _apiHelper.getOne<UserModel>(
      UserEndpoint.me,
      host: ApiHost.profile,
      throwOnError: false,
      parser: UserModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'Fetching current user failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }
}
