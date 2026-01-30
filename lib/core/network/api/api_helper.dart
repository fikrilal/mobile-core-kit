import 'package:dio/dio.dart';
import 'package:mobile_core_kit/core/configs/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/network/api/api_paginated_result.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/api/no_data.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service_impl.dart';

typedef JsonParser<R> = R Function(Map<String, dynamic> json);
typedef ItemParser<R> = JsonParser<R>;

class ApiHelper {
  ApiHelper(this._dio, {ConnectivityService? connectivity})
    : _connectivity = connectivity ?? ConnectivityServiceImpl();

  final Dio _dio;
  final ConnectivityService _connectivity;

  /* ────────────────────────────────────────────────────────────── */
  /*  PUBLIC METHODS – thin wrappers around one private _request   */
  /* ────────────────────────────────────────────────────────────── */

  /* ───────────────── GET ONE ───────────────── */
  Future<ApiResponse<R>> getOne<R>(
    String path, {
    required JsonParser<R> parser,
    ApiHost host = ApiHost.core,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    bool checkConnectivity = true,
    bool throwOnError = true,
    bool requiresAuth = true,
  }) => _request<R>(
    method: 'GET',
    path: path,
    host: host,
    queryParameters: queryParameters,
    headers: headers,
    options: options,
    cancelToken: cancelToken,
    checkConnectivity: checkConnectivity,
    throwOnError: throwOnError,
    requiresAuth: requiresAuth,
    parser: (raw) => parser(raw as Map<String, dynamic>),
  );

  /* ───────────── GET LIST ───────────── */
  Future<ApiResponse<List<R>>> getList<R>(
    String path, {
    required JsonParser<R> itemParser,
    ApiHost host = ApiHost.core,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    bool checkConnectivity = true,
    bool throwOnError = true,
    bool requiresAuth = true,
  }) => _request<List<R>>(
    method: 'GET',
    path: path,
    host: host,
    queryParameters: queryParameters,
    headers: headers,
    options: options,
    cancelToken: cancelToken,
    checkConnectivity: checkConnectivity,
    throwOnError: throwOnError,
    requiresAuth: requiresAuth,

    // 👇 return **List<R>**, not R
    parser: (raw) {
      final list = raw as List;
      return list
          .map((e) => itemParser(e as Map<String, dynamic>))
          .toList(growable: false);
    },
  );

  /* ───────────────── GET PAGINATED ──────────── */
  Future<ApiResponse<ApiPaginatedResult<R>>> getPaginated<R>(
    String path, {
    required JsonParser<R> itemParser,
    ApiHost host = ApiHost.core,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    bool checkConnectivity = true,
    bool throwOnError = true,
    bool requiresAuth = true,
  }) async {
    // First request the plain List<R> while preserving meta
    final ApiResponse<List<R>> listResp = await _request<List<R>>(
      method: 'GET',
      path: path,
      host: host,
      queryParameters: queryParameters,
      headers: headers,
      options: options,
      cancelToken: cancelToken,
      checkConnectivity: checkConnectivity,
      throwOnError: throwOnError,
      requiresAuth: requiresAuth,
      parser: (raw) {
        // raw will be List<dynamic> coming from ApiResponse.data
        final list = raw as List;
        return list.map((e) => itemParser(e as Map<String, dynamic>)).toList();
      },
    );

    if (listResp.isError) {
      return ApiResponse<ApiPaginatedResult<R>>.error(
        message: listResp.message,
        code: listResp.code,
        traceId: listResp.traceId,
        errors: listResp.errors,
        meta: listResp.meta,
        statusCode: listResp.statusCode,
      );
    }

    final meta = listResp.meta;
    final nextCursor = meta?['nextCursor'] as String?;
    final limit = (meta?['limit'] as num?)?.toInt();
    final additionalMeta = meta == null
        ? null
        : (Map<String, dynamic>.from(meta)
            ..remove('nextCursor')
            ..remove('limit'));

    final paginated = ApiPaginatedResult<R>(
      items: listResp.data ?? const [],
      nextCursor: nextCursor,
      limit: limit,
      additionalMeta: additionalMeta == null || additionalMeta.isEmpty
          ? null
          : additionalMeta,
    );

    return ApiResponse<ApiPaginatedResult<R>>.success(
      data: paginated,
      message: listResp.message,
      code: listResp.code,
      traceId: listResp.traceId,
      meta: listResp.meta,
      statusCode: listResp.statusCode,
    );
  }

  /* ───────────────── POST PAGINATED ──────────── */
  Future<ApiResponse<ApiPaginatedResult<R>>> postPaginated<R>(
    String path, {
    required JsonParser<R> itemParser,
    ApiHost host = ApiHost.core,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    bool checkConnectivity = true,
    bool throwOnError = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    // First request the plain List<R> while preserving meta
    final ApiResponse<List<R>> listResp = await _request<List<R>>(
      method: 'POST',
      path: path,
      host: host,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      options: options,
      cancelToken: cancelToken,
      checkConnectivity: checkConnectivity,
      throwOnError: throwOnError,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      requiresAuth: requiresAuth,
      parser: (raw) {
        // raw will be List<dynamic> coming from ApiResponse.data
        final list = raw as List;
        return list
            .map((e) => itemParser(e as Map<String, dynamic>))
            .toList(growable: false);
      },
    );

    if (listResp.isError) {
      return ApiResponse<ApiPaginatedResult<R>>.error(
        message: listResp.message,
        code: listResp.code,
        traceId: listResp.traceId,
        errors: listResp.errors,
        meta: listResp.meta,
        statusCode: listResp.statusCode,
      );
    }

    final meta = listResp.meta;
    final nextCursor = meta?['nextCursor'] as String?;
    final limit = (meta?['limit'] as num?)?.toInt();
    final additionalMeta = meta == null
        ? null
        : (Map<String, dynamic>.from(meta)
            ..remove('nextCursor')
            ..remove('limit'));

    final paginated = ApiPaginatedResult<R>(
      items: listResp.data ?? const [],
      nextCursor: nextCursor,
      limit: limit,
      additionalMeta: additionalMeta == null || additionalMeta.isEmpty
          ? null
          : additionalMeta,
    );

    return ApiResponse<ApiPaginatedResult<R>>.success(
      data: paginated,
      message: listResp.message,
      code: listResp.code,
      traceId: listResp.traceId,
      meta: listResp.meta,
      statusCode: listResp.statusCode,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    ApiHost host = ApiHost.core,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    JsonParser<T>? parser,
    bool checkConnectivity = true,
    bool throwOnError = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) => _request<T>(
    method: 'POST',
    path: path,
    host: host,
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    options: options,
    cancelToken: cancelToken,
    parser: parser == null
        ? null
        : (raw) => parser(raw as Map<String, dynamic>),
    checkConnectivity: checkConnectivity,
    throwOnError: throwOnError,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
    requiresAuth: requiresAuth,
  );

  Future<ApiResponse<T>> put<T>(
    String path, {
    ApiHost host = ApiHost.core,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    JsonParser<T>? parser,
    bool checkConnectivity = true,
    bool throwOnError = true,
    bool requiresAuth = true,
  }) => _request<T>(
    method: 'PUT',
    path: path,
    host: host,
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    options: options,
    cancelToken: cancelToken,
    parser: parser == null
        ? null
        : (raw) => parser(raw as Map<String, dynamic>),
    checkConnectivity: checkConnectivity,
    throwOnError: throwOnError,
    requiresAuth: requiresAuth,
  );

  Future<ApiResponse<T>> delete<T>(
    String path, {
    ApiHost host = ApiHost.core,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    JsonParser<T>? parser,
    bool checkConnectivity = true,
    bool throwOnError = true,
    bool requiresAuth = true,
  }) => _request<T>(
    method: 'DELETE',
    path: path,
    host: host,
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    options: options,
    cancelToken: cancelToken,
    parser: parser == null
        ? null
        : (raw) => parser(raw as Map<String, dynamic>),
    checkConnectivity: checkConnectivity,
    throwOnError: throwOnError,
    requiresAuth: requiresAuth,
  );

  Future<ApiResponse<T>> patch<T>(
    String path, {
    ApiHost host = ApiHost.core,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    JsonParser<T>? parser,
    bool checkConnectivity = true,
    bool throwOnError = true,
    bool requiresAuth = true,
  }) => _request<T>(
    method: 'PATCH',
    path: path,
    host: host,
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    options: options,
    cancelToken: cancelToken,
    parser: parser == null
        ? null
        : (raw) => parser(raw as Map<String, dynamic>),
    checkConnectivity: checkConnectivity,
    throwOnError: throwOnError,
    requiresAuth: requiresAuth,
  );

  /// Flexible variant of POST that does not force-cast `data` to Map.
  /// Useful when the server returns wrapper {status,data,...} but `data`
  /// can be either a Map or a List. The `parser` receives raw `data`.
  Future<ApiResponse<T>> postFlexible<T>(
    String path, {
    ApiHost host = ApiHost.core,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    bool checkConnectivity = true,
    bool throwOnError = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) => _request<T>(
    method: 'POST',
    path: path,
    host: host,
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    options: options,
    cancelToken: cancelToken,
    parser: parser,
    checkConnectivity: checkConnectivity,
    throwOnError: throwOnError,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
    requiresAuth: requiresAuth,
  );

  /* ────────────────────────────────────────────────────────────── */
  /*  INTERNALS                                                    */
  /* ────────────────────────────────────────────────────────────── */

  Future<ApiResponse<T>> _request<T>({
    required String method,
    required String path,
    required ApiHost host,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    required bool checkConnectivity,
    bool throwOnError = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    // 1) online-check ---------------------------------------------------------
    if (checkConnectivity && !_connectivity.isConnected) {
      final failure = ApiFailure(
        message: 'No internet connection',
        statusCode: -1,
      );
      if (throwOnError) throw failure;
      return ApiResponse.error(
        message: failure.message,
        code: failure.code,
        traceId: failure.traceId,
        statusCode: failure.statusCode,
      );
    }

    // 2) merge options --------------------------------------------------------
    final opts = _mergeOptions(
      options,
      headers,
      host,
      requiresAuth: requiresAuth,
    );

    try {
      // 3) fire request -------------------------------------------------------
      final Response response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: opts.copyWith(method: method),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // 4) happy path (2xx) ---------------------------------------------------
      final result = _processResponse<T>(response, parser);
      if (throwOnError && result.isError) {
        throw ApiFailure.fromApiResponse(result);
      }
      return result;
    } on ApiFailure catch (failure) {
      // ApiFailure can be thrown even when Dio doesn't throw (e.g., a 200 response
      // with an "error" envelope). Preserve it rather than wrapping as "unexpected".
      if (throwOnError) rethrow;
      return ApiResponse.error(
        statusCode: failure.statusCode,
        message: failure.message,
        code: failure.code,
        traceId: failure.traceId,
        errors: failure.validationErrors,
      );
    } on DioException catch (e, st) {
      // 5) network / 4xx / 5xx errors ----------------------------------------
      Log.error('ApiHelper DioException: $e', e, st, false, 'ApiHelper');

      final failure = ApiFailure.fromDioException(e);
      if (throwOnError) throw failure;
      return ApiResponse.error(
        statusCode: failure.statusCode,
        message: failure.message,
        code: failure.code,
        traceId: failure.traceId,
        errors: failure.validationErrors,
      );
    } catch (e, st) {
      // 6) anything else (parsing etc.) ---------------------------------------
      Log.wtf('ApiHelper unexpected error: $e', e, st, false, 'ApiHelper');
      final failure = ApiFailure(
        message: 'Unexpected error: ${e.toString()}',
        statusCode: -3,
      );
      if (throwOnError) throw failure;
      return ApiResponse.error(
        statusCode: failure.statusCode,
        message: failure.message,
        code: failure.code,
        traceId: failure.traceId,
      );
    }
  }

  Options _mergeOptions(
    Options? base,
    Map<String, String>? headers,
    ApiHost host, {
    required bool requiresAuth,
  }) {
    final merged = (base ?? Options()).copyWith();

    // caller-headers override duplicated keys
    merged.headers = {...?merged.headers, ...?headers};

    merged.extra ??= <String, dynamic>{};
    merged.extra!['host'] = host;
    merged.extra!['requiresAuth'] = requiresAuth;

    // keep Dio's default validateStatus (200–299) so 4xx/5xx throw
    return merged;
  }

  /* ────────────────────────────────────────────────────────────── */
  /*  RESPONSE PARSING                                             */
  /* ────────────────────────────────────────────────────────────── */

  ApiResponse<T> _processResponse<T>(
    Response response,
    T Function(dynamic)? parser,
  ) {
    final int statusCode = response.statusCode ?? -1;
    final String? traceId = response.headers.value('x-request-id');

    // Handle 204 NO CONTENT ---------------------------------------------------
    if (statusCode == 204) {
      if (T == ApiNoData) {
        return ApiResponse<T>.success(
          data: const ApiNoData() as T,
          traceId: traceId,
          statusCode: statusCode,
        );
      }
      return ApiResponse<T>.success(
        data: null as T,
        traceId: traceId,
        statusCode: statusCode,
      );
    }

    final raw = response.data;

    // Backend standard envelope: { data, meta? }
    return _parseData<T>(raw, parser, statusCode, traceId);
  }

  ApiResponse<T> _parseData<T>(
    dynamic rawData,
    T Function(dynamic)? parser,
    int statusCode,
    String? traceId,
  ) {
    try {
      if (parser == null && T == ApiNoData) {
        return ApiResponse<T>.success(
          data: const ApiNoData() as T,
          traceId: traceId,
          statusCode: statusCode,
        );
      }

      final Map<String, dynamic>? meta =
          (rawData is Map && rawData['meta'] is Map)
          ? Map<String, dynamic>.from(rawData['meta'] as Map)
          : null;

      final dynamic effectiveRaw =
          (rawData is Map && rawData.containsKey('data'))
          ? rawData['data']
          : rawData;

      T parsed;

      if (parser != null) {
        parsed = parser(effectiveRaw);
      } else {
        // Fallback for primitive or already-typed data.
        parsed = effectiveRaw as T;
      }

      return ApiResponse<T>.success(
        data: parsed,
        meta: meta,
        traceId: traceId,
        statusCode: statusCode,
      );
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Failed to parse response: $e',
        traceId: traceId,
        statusCode: statusCode,
      );
    }
  }

  /* ─────────────────────────────── */
  /*  GENERIC JSON DESERIALISATION   */
  /* ─────────────────────────────── */
}
