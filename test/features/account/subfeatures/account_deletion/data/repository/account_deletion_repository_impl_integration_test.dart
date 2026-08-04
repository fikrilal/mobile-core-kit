import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/datasource/remote/account_deletion_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/repository/account_deletion_repository_impl.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/account_deletion_action.dart';

import '../../../../../../support/network_test_harness.dart';

ResponseBody _jsonResponse(
  Map<String, dynamic> body,
  int statusCode, {
  String? requestId,
}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      if (requestId != null) 'x-request-id': <String>[requestId],
    },
  );
}

ResponseBody _emptyResponse(int statusCode, {String? requestId}) {
  return ResponseBody.fromString(
    '',
    statusCode,
    headers: <String, List<String>>{
      if (requestId != null) 'x-request-id': <String>[requestId],
    },
  );
}

AccountDeletionRepositoryImpl _buildRepository(HttpFetchHandler onFetch) {
  final apiHelper = createApiHelperForFixtureResponses(onFetch);
  final remote = AccountDeletionRemoteDataSource(apiHelper);
  return AccountDeletionRepositoryImpl(remote);
}

void main() {
  group('AccountDeletionRepositoryImpl integration', () {
    test('deleteAccount(request) maps 204 response to success', () async {
      final repository = _buildRepository((options) async {
        expect(options.method, 'POST');
        expect(options.path, UserEndpoint.meAccountDeletionRequest);
        expect(options.data, isNull);
        return _emptyResponse(204, requestId: 'rid-request-account-deletion');
      });

      final result = await repository.deleteAccount(
        AccountDeletionAction.request,
      );

      expect(result.isRight(), isTrue);
    });

    test(
      'deleteAccount(request) maps conflict response to AuthFailure.unexpected',
      () async {
        final fixture = <String, dynamic>{
          'code': 'CONFLICT',
          'message': 'Account deletion request already exists.',
        };
        final repository = _buildRepository((options) async {
          expect(options.method, 'POST');
          expect(options.path, UserEndpoint.meAccountDeletionRequest);
          return _jsonResponse(
            fixture,
            409,
            requestId: 'rid-request-account-deletion-conflict',
          );
        });

        final result = await repository.deleteAccount(
          AccountDeletionAction.request,
        );

        result.match((failure) {
          expect(failure, const AuthFailure.unexpected(message: 'CONFLICT'));
        }, (_) => fail('Expected Left'));
      },
    );

    test('deleteAccount(cancel) maps 204 response to success', () async {
      final repository = _buildRepository((options) async {
        expect(options.method, 'POST');
        expect(options.path, UserEndpoint.meAccountDeletionCancel);
        expect(options.data, isNull);
        return _emptyResponse(204, requestId: 'rid-cancel-account-deletion');
      });

      final result = await repository.deleteAccount(
        AccountDeletionAction.cancel,
      );

      expect(result.isRight(), isTrue);
    });

    test(
      'deleteAccount(cancel) maps idempotency in-progress response to AuthFailure.unexpected',
      () async {
        final fixture = <String, dynamic>{
          'code': 'IDEMPOTENCY_IN_PROGRESS',
          'message': 'Request is still being processed.',
        };
        final repository = _buildRepository((options) async {
          expect(options.method, 'POST');
          expect(options.path, UserEndpoint.meAccountDeletionCancel);
          return _jsonResponse(
            fixture,
            409,
            requestId: 'rid-cancel-account-deletion-in-progress',
          );
        });

        final result = await repository.deleteAccount(
          AccountDeletionAction.cancel,
        );

        result.match((failure) {
          expect(
            failure,
            const AuthFailure.unexpected(message: 'IDEMPOTENCY_IN_PROGRESS'),
          );
        }, (_) => fail('Expected Left'));
      },
    );
  });
}
