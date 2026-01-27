/// Backend error codes specific to profile image endpoints.
///
/// Source of truth:
/// - `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`
abstract final class ProfileImageErrorCodes {
  ProfileImageErrorCodes._();

  static const usersObjectStorageNotConfigured =
      'USERS_OBJECT_STORAGE_NOT_CONFIGURED';

  static const usersProfileImageNotUploaded = 'USERS_PROFILE_IMAGE_NOT_UPLOADED';
  static const usersProfileImageSizeMismatch = 'USERS_PROFILE_IMAGE_SIZE_MISMATCH';
  static const usersProfileImageContentTypeMismatch =
      'USERS_PROFILE_IMAGE_CONTENT_TYPE_MISMATCH';
}

