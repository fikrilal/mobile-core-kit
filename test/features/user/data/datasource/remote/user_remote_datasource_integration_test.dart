import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/patch_me_request_model.dart';

import '../../../../../support/fixture_loader.dart';
import '../../../../../support/network_test_harness.dart';

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

void main() {
  group('UserRemoteDataSource integration', () {
    test('getMe parses fixture envelope into MeModel', () async {
      final fixture = loadJsonFixtureAsMap('user/me_success_envelope.json');
      final apiHelper = createApiHelperForFixtureResponses((options) async {
        expect(options.method, 'GET');
        expect(options.path, UserEndpoint.me);
        return _jsonResponse(fixture, 200, requestId: 'rid-get-me');
      });

      final datasource = UserRemoteDataSource(apiHelper);
      final response = await datasource.getMe();

      expect(response.isSuccess, isTrue);
      expect(response.traceId, 'rid-get-me');
      expect(response.data, isNotNull);
      expect(response.data!.id, '3d2c7b2a-2dd6-46a5-8f8e-3b5de8a5b0f0');
      expect(response.data!.email, 'user@example.com');
      expect(response.data!.roles, const <String>['USER', 'ADMIN']);
      expect(response.data!.authMethods, const <String>['PASSWORD', 'GOOGLE']);
      expect(response.data!.profile.givenName, 'Dante');
      expect(response.data!.accountDeletion, isNotNull);
      expect(
        response.data!.accountDeletion!.scheduledFor,
        '2026-02-09T12:34:56.789Z',
      );
    });

    test(
      'patchMe sends expected body + idempotency key and parses response',
      () async {
        final fixture = loadJsonFixtureAsMap(
          'user/patch_me_success_envelope.json',
        );

        final apiHelper = createApiHelperForFixtureResponses((options) async {
          expect(options.method, 'PATCH');
          expect(options.path, UserEndpoint.me);
          expect(options.headers['Idempotency-Key']?.toString(), 'idem-123');
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
          return _jsonResponse(fixture, 200, requestId: 'rid-patch-me');
        });

        final datasource = UserRemoteDataSource(apiHelper);
        final response = await datasource.patchMe(
          request: const PatchMeRequestModel(
            profile: PatchMeProfileModel(
              displayName: 'Dante A.',
              givenName: 'Dante',
              familyName: 'A.',
            ),
          ),
          idempotencyKey: 'idem-123',
        );

        expect(response.isSuccess, isTrue);
        expect(response.traceId, 'rid-patch-me');
        expect(response.data, isNotNull);
        expect(response.data!.profile.displayName, 'Dante A.');
        expect(response.data!.profile.familyName, 'A.');
      },
    );

    test(
      'getMe returns error response for unauthorized RFC7807 payload',
      () async {
        final fixture = loadJsonFixtureAsMap(
          'user/me_unauthorized_problem.json',
        );
        final apiHelper = createApiHelperForFixtureResponses((options) async {
          expect(options.method, 'GET');
          expect(options.path, UserEndpoint.me);
          return _jsonResponse(fixture, 401, requestId: 'rid-unauthorized');
        });

        final datasource = UserRemoteDataSource(apiHelper);
        final response = await datasource.getMe();

        expect(response.isError, isTrue);
        expect(response.statusCode, 401);
        expect(response.code, 'UNAUTHORIZED');
        expect(response.traceId, 'trace-unauthorized-1');
        expect(response.message, 'Unauthorized');
      },
    );
  });
}
