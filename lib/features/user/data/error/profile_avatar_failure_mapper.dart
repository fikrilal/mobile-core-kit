import 'package:mobile_core_kit/core/network/download/presigned_download_client.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

AuthFailure mapProfileAvatarDownloadFailure(PresignedDownloadFailure failure) {
  final statusCode = failure.statusCode;
  if (statusCode == -1 || statusCode == -2) {
    return const AuthFailure.network();
  }
  return const AuthFailure.unexpected();
}

