import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_failure.dart';

extension ApiResponseEitherX<T> on ApiResponse<T> {
  /// Converts `ApiResponse<T>` into `Either<ApiFailure, T>`.
  /// If the response is not a success or has null data, returns a left
  /// with a synthesized ApiFailure using [fallbackMessage] when message is null.
  Either<ApiFailure, T> toEitherWithFallback(String fallbackMessage) {
    if (isSuccess && data != null) {
      return right(data as T);
    }
    return left(
      ApiFailure(
        message: message ?? fallbackMessage,
        statusCode: statusCode,
        code: code,
        traceId: traceId,
        validationErrors: errors,
      ),
    );
  }
}
