import 'package:fpdart/fpdart.dart';
import 'api_response.dart';
import '../exceptions/api_failure.dart';

extension ApiResponseEitherX<T> on ApiResponse<T> {
  /// Converts ApiResponse<T> into Either<ApiFailure, T>.
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
        validationErrors: errors,
      ),
    );
  }
}

