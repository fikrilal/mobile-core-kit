import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/datasource/remote/profile_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/model/remote/patch_me_request_model.dart';

import '../../../../../../../support/fixture_loader.dart';
import '../../../../../../../support/network_test_harness.dart';

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
  group('ProfileRemoteDataSource integration', () {
    test(
      'patchMeProfile sends expected body + idempotency key and parses response',
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

        final datasource = ProfileRemoteDataSource(apiHelper);
        final response = await datasource.patchMeProfile(
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
  });
}
