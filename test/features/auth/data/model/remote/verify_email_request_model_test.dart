import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/verify_email_request_model.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_verification_token.dart';

void main() {
  test(
    'toJson matches backend verify email request contract (omits nulls)',
    () {
      const model = VerifyEmailRequestModel(token: 'token');

      expect(model.toJson(), <String, dynamic>{'token': 'token'});
    },
  );

  test('maps a validated EmailVerificationToken into the wire model', () {
    final token = EmailVerificationToken.create(
      ' token ',
    ).getOrElse((_) => throw StateError('expected valid token'));

    final model = VerifyEmailRequestModel.fromToken(token);

    expect(model.token, 'token');
  });
}
