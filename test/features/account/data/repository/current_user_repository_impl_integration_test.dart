import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/account/data/datasource/remote/me_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/data/repository/current_user_repository_impl.dart';

import '../../../../support/fixture_loader.dart';
import '../../../../support/network_test_harness.dart';

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

CurrentUserRepositoryImpl _buildRepository(HttpFetchHandler onFetch) {
  final apiHelper = createApiHelperForFixtureResponses(onFetch);
  final remote = MeRemoteDataSource(apiHelper);
  return CurrentUserRepositoryImpl(remote);
}

void main() {
  group('CurrentUserRepositoryImpl integration', () {
    test('getCurrentUser maps fixture JSON to UserEntity', () async {
      final fixture = loadJsonFixtureAsMap('user/me_success_envelope.json');
      final repository = _buildRepository((options) async {
        expect(options.method, 'GET');
        expect(options.path, UserEndpoint.me);
        return _jsonResponse(fixture, 200, requestId: 'rid-get-me-repo');
      });

      final result = await repository.getCurrentUser();

      result.match((failure) => fail('Expected Right, got $failure'), (user) {
        expect(user.id, '3d2c7b2a-2dd6-46a5-8f8e-3b5de8a5b0f0');
        expect(user.email, 'user@example.com');
        expect(user.emailVerified, isTrue);
        expect(user.profile.displayName, 'Dante Alighieri');
        expect(user.roles, const <String>['USER', 'ADMIN']);
      });
    });

    test(
      'getCurrentUser maps unauthorized response to AuthFailure.unauthenticated',
      () async {
        final fixture = loadJsonFixtureAsMap(
          'user/me_unauthorized_problem.json',
        );
        final repository = _buildRepository((options) async {
          expect(options.method, 'GET');
          expect(options.path, UserEndpoint.me);
          return _jsonResponse(
            fixture,
            401,
            requestId: 'rid-unauthorized-repo',
          );
        });

        final result = await repository.getCurrentUser();

        result.match((failure) {
          expect(failure, const AuthFailure.unauthenticated());
        }, (_) => fail('Expected Left'));
      },
    );
  });
}
