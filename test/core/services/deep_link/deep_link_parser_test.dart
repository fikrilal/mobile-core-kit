import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_parser.dart';

void main() {
  group('DeepLinkParser', () {
    test('parses allowlisted https://orymu.com links to internal locations', () {
      final parser = DeepLinkParser();

      expect(
        parser.parseExternalUri(Uri.parse('https://orymu.com/home')),
        '/home',
      );
      expect(
        parser.parseExternalUri(Uri.parse('https://orymu.com/profile?tab=security')),
        '/profile?tab=security',
      );
    });

    test('rejects non-allowlisted hosts and paths', () {
      final parser = DeepLinkParser();

      expect(
        parser.parseExternalUri(Uri.parse('https://evil.com/home')),
        isNull,
      );
      expect(
        parser.parseExternalUri(Uri.parse('https://orymu.com/unknown')),
        isNull,
      );
    });
  });
}

