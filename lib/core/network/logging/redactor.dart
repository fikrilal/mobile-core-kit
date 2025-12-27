class Redactor {
  static const defaultHeaderKeys = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'x-auth-token',
    'x-access-token',
  };

  static const defaultBodyKeys = {
    'password',
    'token',
    'otp',
    'pin',
    'email',
  };

  static Map<String, dynamic> redactMap(
    Map<String, dynamic> data, {
    Set<String> bodyKeys = defaultBodyKeys,
  }) {
    final result = <String, dynamic>{};
    data.forEach((key, value) {
      final lower = key.toLowerCase();
      final isSensitive =
          bodyKeys.contains(lower) ||
          // Catch common variants like accessToken/refreshToken/idToken.
          //
          // Note: keep token type visible (e.g., "Bearer") for debugging.
          (lower.contains('token') &&
              lower != 'tokentype' &&
              lower != 'token_type');
      if (isSensitive) {
        if (value is Map<String, dynamic>) {
          result[key] = redactMap(value, bodyKeys: bodyKeys);
        } else if (value is List) {
          result[key] = value.map((e) {
            if (e is Map<String, dynamic>) return redactMap(e, bodyKeys: bodyKeys);
            return _maskValue(e);
          }).toList();
        } else {
          result[key] = _maskValue(value);
        }
      } else if (value is Map<String, dynamic>) {
        result[key] = redactMap(value, bodyKeys: bodyKeys);
      } else if (value is List) {
        result[key] = value.map((e) {
          if (e is Map<String, dynamic>) return redactMap(e, bodyKeys: bodyKeys);
          return e;
        }).toList();
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  static Map<String, dynamic> redactHeaders(
    Map<String, dynamic> headers, {
    Set<String> headerKeys = defaultHeaderKeys,
  }) {
    final result = <String, dynamic>{};
    headers.forEach((key, value) {
      final lower = key.toLowerCase();
      if (headerKeys.contains(lower)) {
        result[key] = _maskValue(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  static String _maskValue(dynamic value) {
    final s = value?.toString() ?? '';
    if (s.isEmpty) return '';
    if (s.length <= 6) return '***';
    return '${s.substring(0, 3)}***${s.substring(s.length - 3)}';
  }
}
