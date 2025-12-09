/// Extension to safely convert dynamic JSON to typed parsers
extension JsonParser on dynamic {
  /// Safely converts dynamic JSON to Map<String, dynamic> and applies parser
  T parseWith<T>(T Function(Map<String, dynamic>) parser) {
    if (this == null) {
      throw const FormatException('Cannot parse null JSON');
    }

    if (this is! Map) {
      throw FormatException('Expected JSON object but got $runtimeType');
    }

    final map = Map<String, dynamic>.from(this as Map);
    return parser(map);
  }
}

/// Helper function to create type-safe parsers from fromJson methods
T Function(dynamic) jsonParser<T>(T Function(Map<String, dynamic>) fromJson) {
  return (dynamic json) => json.parseWith(fromJson);
}
