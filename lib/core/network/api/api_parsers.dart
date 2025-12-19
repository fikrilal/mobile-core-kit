import '../../utilities/json_extensions.dart';

/// Helpers for parsing common backend envelope shapes.
///
/// Keep this small and focused; it should not contain feature-level logic.
class ApiParsers {
  ApiParsers._();

  /// Parses responses shaped as `{ "data": <T> }`.
  ///
  /// Example:
  /// ```json
  /// { "data": { "id": "1", "email": "a@b.com" } }
  /// ```
  static T Function(Map<String, dynamic>) dataEnvelope<T>(
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return _DataEnvelopeParser(fromJson).call;
  }
}

class _DataEnvelopeParser<T> {
  const _DataEnvelopeParser(this._fromJson);

  final T Function(Map<String, dynamic>) _fromJson;

  T call(Map<String, dynamic> json) {
    final raw = json['data'];
    return JsonParser(raw).parseWith(_fromJson);
  }
}
