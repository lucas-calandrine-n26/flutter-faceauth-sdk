import 'dart:convert';

import 'package:caf_face_authenticator/src/face_authenticator_api.dart';
import 'package:caf_face_authenticator/src/face_authenticator_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_web_server/mock_web_server.dart';

import '../mock/mock.dart';

void main() {
  late MockWebServer server;
  late FaceAuthenticatorApi faceAuthenticatorApi;

  setUp(() async {
    server = await startMockServer();
    faceAuthenticatorApi = FaceAuthenticatorApi(
        'token', 'clientId', 'clientSecret', 'personId',
        baseUrl: server.url);
  });

  tearDown(() async {
    await shutDownMockServer(server);
  });

  group("GIVEN a FaceAuthenticatorApi instance ", () {
    test(
        "AND a valid verifyFaceMatch WHEN isMatch is true and the http status code is equal to 200 returns false",
        () async {
      server.enqueue(httpCode: 200, body: jsonEncode({'isMatch': true}));
      expect(await faceAuthenticatorApi.verifyFaceMatch('sessionId'), true);
    });

    test(
        "AND a valid verifyFaceMatch WHEN isMatch is false and the http status code is equal to 200 returns false",
        () async {
      server.enqueue(httpCode: 200, body: jsonEncode({'isMatch': false}));
      expect(await faceAuthenticatorApi.verifyFaceMatch('sessionId'), false);
    });

    test(
        "AND a valid verifyFaceMatch WHEN http status code is other than 200 throw FaceAuthFaceMathApiException",
        () async {
      server.enqueue(httpCode: 400);
      expect(
          () async => await faceAuthenticatorApi.verifyFaceMatch('sessionId'),
          throwsA(isA<FaceAuthenticatorFaceMathApiException>()));
    });

    test(
        "AND a valid verifyLiveness WHEN http status code is equal to 200 returns true",
        () async {
      server.enqueue(httpCode: 200);
      expect(await faceAuthenticatorApi.verifyLiveness('sessionId'), true);
    });

    test(
        "AND a valid verifyLiveness WHEN http status code is other than 200 throw FaceAuthLivenessApiException",
        () async {
      server.enqueue(httpCode: 400);
      expect(() async => await faceAuthenticatorApi.verifyLiveness('sessionId'),
          throwsA(isA<FaceAuthenticatorLivenessApiException>()));
    });
  });
}
