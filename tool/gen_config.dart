import 'dart:io';

import 'package:mobile_core_kit_cli/mobile_core_kit_cli.dart';

Future<void> main(List<String> args) async {
  final exitCode = await MobilekitCli().run(['config', 'generate', ...args]);
  if (exitCode != 0) {
    exit(exitCode);
  }
}
