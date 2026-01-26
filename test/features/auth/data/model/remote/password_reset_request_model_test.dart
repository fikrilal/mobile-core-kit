import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/password_reset_request_model.dart';

void main() {
  test(
    'toJson matches backend password reset request contract (omits nulls)',
    () {
      const model = PasswordResetRequestModel(email: 'user@example.com');

      expect(model.toJson(), <String, dynamic>{'email': 'user@example.com'});
    },
  );
}
