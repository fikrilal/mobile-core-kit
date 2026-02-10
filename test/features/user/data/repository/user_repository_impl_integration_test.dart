import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/repository/user_repository_impl.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';

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

UserRepositoryImpl _buildRepository(HttpFetchHandler onFetch) {
  final apiHelper = createApiHelperForFixtureResponses(onFetch);
  final remote = UserRemoteDataSource(apiHelper);
  return UserRepositoryImpl(remote);
}

void main() {
  group('UserRepositoryImpl integration', () {
    test('getMe maps fixture JSON to UserEntity', () async {
      final fixture = loadJsonFixtureAsMap('user/me_success_envelope.json');
      final repository = _buildRepository((options) async {
        expect(options.method, 'GET');
        expect(options.path, UserEndpoint.me);
        return _jsonResponse(fixture, 200, requestId: 'rid-get-me-repo');
      });

      final result = await repository.getMe();

      result.match((failure) => fail('Expected Right, got $failure'), (user) {
        expect(user.id, '3d2c7b2a-2dd6-46a5-8f8e-3b5de8a5b0f0');
        expect(user.email, 'user@example.com');
        expect(user.emailVerified, isTrue);
        expect(user.profile.displayName, 'Dante Alighieri');
        expect(user.roles, const <String>['USER', 'ADMIN']);
      });
    });

    test(
      'patchMeProfile sends expected payload and maps response to UserEntity',
      () async {
        final fixture = loadJsonFixtureAsMap(
          'user/patch_me_success_envelope.json',
        );
        final repository = _buildRepository((options) async {
          expect(options.method, 'PATCH');
          expect(options.path, UserEndpoint.me);
          expect(
            options.data,
            equals(<String, dynamic>{
              'profile': <String, dynamic>{
                'displayName': 'Dante A.',
                'givenName': 'Dante',
                'familyName': 'A.',
              },
            }),
          );
          return _jsonResponse(fixture, 200, requestId: 'rid-patch-me-repo');
        });

        final result = await repository.patchMeProfile(
          const PatchMeProfileRequestEntity(
            givenName: 'Dante',
            familyName: 'A.',
            displayName: 'Dante A.',
          ),
        );

        result.match((failure) => fail('Expected Right, got $failure'), (user) {
          expect(user.profile.displayName, 'Dante A.');
          expect(user.profile.givenName, 'Dante');
          expect(user.profile.familyName, 'A.');
        });
      },
    );

    test(
      'getMe maps unauthorized response to AuthFailure.unauthenticated',
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

        final result = await repository.getMe();

        result.match((failure) {
          expect(failure, const AuthFailure.unauthenticated());
        }, (_) => fail('Expected Left'));
      },
    );

    test(
      'patchMeProfile maps validation response to AuthFailure.validation',
      () async {
        final fixture = loadJsonFixtureAsMap(
          'user/patch_me_validation_problem.json',
        );
        final repository = _buildRepository((options) async {
          expect(options.method, 'PATCH');
          expect(options.path, UserEndpoint.me);
          return _jsonResponse(fixture, 422, requestId: 'rid-validation-repo');
        });

        final result = await repository.patchMeProfile(
          const PatchMeProfileRequestEntity(givenName: ''),
        );

        result.match((failure) {
          expect(
            failure,
            const AuthFailure.validation(<ValidationError>[
              ValidationError(
                field: 'profile.givenName',
                message: 'Given name must be at least 1 character.',
                code: 'minLength',
              ),
            ]),
          );
        }, (_) => fail('Expected Left'));
      },
    );
  });
}
