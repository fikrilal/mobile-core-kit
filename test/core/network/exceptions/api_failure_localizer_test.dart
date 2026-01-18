import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_failure_localizer.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiFailureLocalizer', () {
    test('maps offline/timeout/auth/server cases', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        messageFor(ApiFailure(message: 'x', statusCode: -1), l10n),
        l10n.errorsOffline,
      );
      expect(
        messageFor(ApiFailure(message: 'x', statusCode: -2), l10n),
        l10n.errorsTimeout,
      );
      expect(
        messageFor(ApiFailure(message: 'x', statusCode: 401), l10n),
        l10n.errorsUnauthenticated,
      );
      expect(
        messageFor(ApiFailure(message: 'x', statusCode: 403), l10n),
        l10n.errorsForbidden,
      );
      expect(
        messageFor(ApiFailure(message: 'x', statusCode: 429), l10n),
        l10n.errorsTooManyRequests,
      );
      expect(
        messageFor(ApiFailure(message: 'x', statusCode: 500), l10n),
        l10n.errorsServer,
      );
    });

    test('prefers mapping by error code when present', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        messageFor(
          ApiFailure(
            message: 'x',
            statusCode: 500,
            code: ApiErrorCodes.rateLimited,
          ),
          l10n,
        ),
        l10n.errorsTooManyRequests,
      );
    });

    test('falls back to unexpected for unknown cases', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        messageFor(ApiFailure(message: 'x', statusCode: 418), l10n),
        l10n.errorsUnexpected,
      );
      expect(messageFor(ApiFailure(message: 'x'), l10n), l10n.errorsUnexpected);
    });
  });
}
