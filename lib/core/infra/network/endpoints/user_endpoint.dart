class UserEndpoint {
  UserEndpoint._();

  static const String me = '/me';
  static const String meSessions = '/me/sessions';
  static const String meAccountDeletionRequest = '/me/account-deletion/request';
  static const String meAccountDeletionCancel = '/me/account-deletion/cancel';
  static const String mePushToken = '/me/push-token';
  static const String meProfileImageUpload = '/me/profile-image/upload';
  static const String meProfileImageComplete = '/me/profile-image/complete';
  static const String meProfileImage = '/me/profile-image';
  static const String meProfileImageUrl = '/me/profile-image/url';

  static String meSessionRevoke(String sessionId) {
    final encodedSessionId = Uri.encodeComponent(sessionId);
    return '$meSessions/$encodedSessionId/revoke';
  }
}
