import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

String _stripDigits(String value) => value.replaceAll(RegExp(r'\d+'), '');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('English pluralization uses a distinct one/other form', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    final one = l10n.commonItemsCount(count: 1);
    final other = l10n.commonItemsCount(count: 2);

    expect(one, contains('1'));
    expect(other, contains('2'));
    expect(_stripDigits(one), isNot(_stripDigits(other)));
  });

  test('Indonesian pluralization remains stable across counts', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('id'));

    final one = l10n.commonItemsCount(count: 1);
    final other = l10n.commonItemsCount(count: 2);

    expect(one, contains('1'));
    expect(other, contains('2'));
    expect(_stripDigits(one), _stripDigits(other));
  });
}
