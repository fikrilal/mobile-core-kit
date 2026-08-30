import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/password_reset_confirm_request_model.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password_reset_credentials.dart';

void main() {
  test(
    'toJson matches backend password reset confirm contract (omits nulls)',
    () {
      const model = PasswordResetConfirmRequestModel(
        token: 'token',
        newPassword: '1234567890',
      );

      expect(model.toJson(), <String, dynamic>{
        'token': 'token',
        'newPassword': '1234567890',
      });
    },
  );

  test('maps validated credentials into the wire model', () {
    final credentials = PasswordResetCredentials.create(
      token: ' token ',
      newPassword: '1234567890',
    ).getOrElse((_) => throw StateError('expected valid credentials'));

    final model = PasswordResetConfirmRequestModel.fromCredentials(credentials);

    expect(model.token, 'token');
    expect(model.newPassword, '1234567890');
  });
}
