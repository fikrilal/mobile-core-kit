import 'dart:convert';
import 'dart:io';

Map<String, dynamic> loadJsonFixtureAsMap(String relativePath) {
  final file = File('test/fixtures/$relativePath');
  if (!file.existsSync()) {
    throw StateError('Fixture not found: ${file.path}');
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw FormatException(
      'Fixture must decode to a JSON object map: ${file.path}',
    );
  }

  return decoded;
}
