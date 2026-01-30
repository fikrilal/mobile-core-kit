import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/infra/network/download/presigned_download_client.dart';

AuthFailure mapProfileAvatarDownloadFailure(PresignedDownloadFailure failure) {
  final statusCode = failure.statusCode;
  if (statusCode == -1 || statusCode == -2) {
    return const AuthFailure.network();
  }
  return const AuthFailure.unexpected();
}
