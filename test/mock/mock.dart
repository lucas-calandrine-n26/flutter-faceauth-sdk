import 'package:caf_face_authenticator/src/face_authenticator_api.dart';
import 'package:cs_liveness_flutter/cs_liveness_flutter.dart';
import 'package:mock_web_server/mock_web_server.dart';
import 'package:mocktail/mocktail.dart';

class CsLivenessMock extends Mock implements CsLiveness {}

class FaceAuthenticatorApiMock extends Mock implements FaceAuthenticatorApi {}

Future<MockWebServer> startMockServer() async {
  final server = MockWebServer();
  await server.start();
  return server;
}

Future<void> shutDownMockServer(MockWebServer server) async {
  server.shutdown();
}

MockResponse mockServerResponse(String payload, {httpCode = 200}) =>
    MockResponse()
      ..httpCode = httpCode
      ..body = payload
      ..headers = {'content-type': 'application/json; charset=utf-8'};
