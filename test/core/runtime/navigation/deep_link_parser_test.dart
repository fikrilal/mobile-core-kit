import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_parser.dart';

void main() {
  group('DeepLinkParser', () {
    test(
      'parses allowlisted https://links.fikril.dev links to internal locations',
      () {
        final parser = DeepLinkParser();

        expect(
          parser.parseExternalUri(Uri.parse('https://links.fikril.dev/home')),
          '/home',
        );
        expect(
          parser.parseExternalUri(
            Uri.parse('https://links.fikril.dev/profile?tab=security'),
          ),
          '/profile?tab=security',
        );
        expect(
          parser.parseExternalUri(
            Uri.parse('https://links.fikril.dev/verify-email?token=abc'),
          ),
          '/auth/email/verify?token=abc',
        );
        expect(
          parser.parseExternalUri(
            Uri.parse('https://links.fikril.dev/reset-password?token=abc'),
          ),
          '/auth/password/reset/confirm?token=abc',
        );
      },
    );

    test('rejects non-allowlisted hosts and paths', () {
      final parser = DeepLinkParser();

      expect(
        parser.parseExternalUri(Uri.parse('https://evil.com/home')),
        isNull,
      );
      expect(
        parser.parseExternalUri(Uri.parse('https://links.fikril.dev/unknown')),
        isNull,
      );
    });
  });
}
