import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/change_password_request_model.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password_change_credentials.dart';

void main() {
  test(
    'toJson matches backend change password request contract (omits nulls)',
    () {
      const model = ChangePasswordRequestModel(
        currentPassword: 'oldpassword123',
        newPassword: 'newpassword123',
      );

      expect(model.toJson(), <String, dynamic>{
        'currentPassword': 'oldpassword123',
        'newPassword': 'newpassword123',
      });
    },
  );

  test('maps validated credentials into the wire model', () {
    final credentials = PasswordChangeCredentials.create(
      currentPassword: 'oldpassword123',
      newPassword: 'newpassword123',
    ).getOrElse((_) => throw StateError('expected valid credentials'));

    final model = ChangePasswordRequestModel.fromCredentials(credentials);

    expect(model.currentPassword, 'oldpassword123');
    expect(model.newPassword, 'newpassword123');
  });
}
