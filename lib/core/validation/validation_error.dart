/// A field-level validation error that can be used across layers.
///
/// This type intentionally lives outside the network layer so that domain code
/// (use cases, failures) can depend on it without importing API/HTTP concepts.
class ValidationError {
  const ValidationError({
    this.field,
    required this.message,
    this.code,
  });

  final String? field;
  final String message;
  final String? code;

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] as String?,
      message: (json['message'] as String?) ?? 'Unknown error',
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (field != null) 'field': field,
      'message': message,
      if (code != null) 'code': code,
    };
  }

  @override
  String toString() =>
      'ValidationError(field: $field, message: $message, code: $code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationError &&
          other.field == field &&
          other.message == message &&
          other.code == code;

  @override
  int get hashCode => Object.hash(field, message, code);
}

