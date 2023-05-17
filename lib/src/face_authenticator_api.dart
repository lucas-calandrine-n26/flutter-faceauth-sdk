import 'dart:convert';
import 'dart:io';
import 'package:caf_face_authenticator/src/face_authenticator_exceptions.dart';
import 'package:http/http.dart' as http;

class FaceAuthenticatorApi {
  static const String _faceLivenessUrl = 'v1/sdks/faces/liveness-partner';
  static const String _faceMatchUrl = 'v1/sdks/faces/authentication-partner';
  static const _sdkVersion = 'Flutter-1.0.0';

  final String baseUrl;
  final String token;
  final String clientId;
  final String clientSecret;
  final String personId;

  FaceAuthenticatorApi(this.token, this.clientId, this.clientSecret, this.personId,
      {this.baseUrl = 'https://api.public.caf.io/'});

  Future<bool> verifyLiveness(String sessionId) async {
    var uri = Uri.parse('$baseUrl$_faceLivenessUrl');
    var body = _getBody(sessionId);
    var headers = _getHeaders();
    var response = await http.post(uri, body: body, headers: headers);
    if (response.statusCode != HttpStatus.ok) {
      throw FaceAuthenticatorLivenessApiException(response);
    }
    return true;
  }

  Future<bool> verifyFaceMatch(String sessionId) async {
    var uri = Uri.parse('$baseUrl$_faceMatchUrl');
    var body = _getBody(sessionId);
    var headers = _getHeaders();
    var response = await http.post(uri, body: body, headers: headers);
    if (response.statusCode != HttpStatus.ok) {
      throw FaceAuthenticatorFaceMathApiException(response);
    }
    return jsonDecode(response.body)['isMatch'];
  }

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
  }

  String _getBody(String sessionId) {
    return jsonEncode({
      'personId': personId,
      'sessionId': sessionId,
      'sdkVersion': _sdkVersion,
    });
  }
}
