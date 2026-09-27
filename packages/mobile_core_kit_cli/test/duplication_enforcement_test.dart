import 'package:mobile_core_kit_cli/src/duplication/duplication_enforcement.dart';
import 'package:mobile_core_kit_cli/src/duplication/duplication_runner.dart';
import 'package:test/test.dart';

void main() {
  test('core blocks actionable groups and advisory profiles do not', () {
    expect(
      exitCodeForActionableGroups(
        enforcement: enforcementFor(DuplicationProfile.core),
        actionableGroupCount: 2,
      ),
      1,
    );
    expect(
      exitCodeForActionableGroups(
        enforcement: enforcementFor(DuplicationProfile.smallHelpers),
        actionableGroupCount: 135,
      ),
      0,
    );
    expect(
      exitCodeForActionableGroups(
        enforcement: enforcementFor(DuplicationProfile.presentation),
        actionableGroupCount: 4,
      ),
      0,
    );
    expect(
      exitCodeForActionableGroups(
        enforcement: enforcementFor(DuplicationProfile.core),
        actionableGroupCount: 0,
      ),
      0,
    );
  });
}
