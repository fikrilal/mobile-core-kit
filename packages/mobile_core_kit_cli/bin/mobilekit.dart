import 'dart:io';

import 'package:mobile_core_kit_cli/mobile_core_kit_cli.dart';

Future<void> main(List<String> args) async {
  exitCode = await MobilekitCli().run(args);
}
