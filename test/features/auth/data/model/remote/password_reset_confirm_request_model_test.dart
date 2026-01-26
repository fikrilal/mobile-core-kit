import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/password_reset_confirm_request_model.dart';

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
}
