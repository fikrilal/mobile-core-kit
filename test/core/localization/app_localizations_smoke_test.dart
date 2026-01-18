import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalizations smoke', () {
    for (final locale in AppLocalizations.supportedLocales) {
      test('loads ${locale.toString()}', () async {
        final l10n = await AppLocalizations.delegate.load(locale);

        expect(l10n.appTitle, isNotEmpty);
        expect(l10n.commonOk, isNotEmpty);
        expect(l10n.commonCancel, isNotEmpty);
        expect(l10n.commonConfirm, isNotEmpty);
        expect(l10n.commonLoading, isNotEmpty);
        expect(l10n.commonStartingUp, isNotEmpty);
        expect(l10n.commonShowPassword, isNotEmpty);
        expect(l10n.commonHidePassword, isNotEmpty);
        expect(l10n.fieldSearchHint, isNotEmpty);
        expect(l10n.commonAvatar, isNotEmpty);

        final avatarFor = l10n.commonAvatarFor(name: 'Ari');
        expect(avatarFor, isNotEmpty);
        expect(avatarFor, contains('Ari'));

        expect(l10n.commonChangeProfilePhoto, isNotEmpty);

        expect(l10n.commonItemsCount(count: 0), isNotEmpty);
        expect(l10n.commonItemsCount(count: 1), isNotEmpty);
        expect(l10n.commonItemsCount(count: 2), isNotEmpty);
      });
    }
  });
}

