import 'dart:convert';
import 'dart:io';

import 'package:faceauth/faceauth.dart';
import 'package:http/http.dart' as http;

class FaceAuthApi {
  static const String _faceLivenessUrl =
      'https://api.public.caf.io/v1/sdks/faces/liveness-partner';
  static const String _faceMatchUrl =
      'https://api.public.caf.io/v1/sdks/faces/authentication-partner';
  static const _sdkVersion = 'Flutter-1.0.0';

  final String token;
  final String clientId;
  final String clientSecret;
  final String personId;

  FaceAuthApi(
    this.token,
    this.clientId,
    this.clientSecret,
    this.personId,
  );

  Future<bool> verifyLiveness(sessionId) async {
    var uri = Uri.parse(_faceLivenessUrl);
    var body = _getBody(sessionId);
    var headers = _getHeaders();
    var response = await http.post(uri, body: body, headers: headers);
    if (response.statusCode != HttpStatus.ok) {
      throw FaceAuthLivenessApiException(response);
    }
    return true;
  }

  Future<bool> verifyFaceMatch(sessionId) async {
    var uri = Uri.parse(_faceMatchUrl);
    var body = _getBody(sessionId);
    var headers = _getHeaders();
    var response = await http.post(uri, body: body, headers: headers);
    if (response.statusCode != HttpStatus.ok) {
      throw FaceAuthFaceMathApiException(response);
    }
    return jsonDecode(response.body)['isMatch'];
  }

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
  }

  String _getBody(sessionId) {
    return jsonEncode({
      'personId': personId,
      'sessionId': sessionId,
      'sdkVersion': _sdkVersion,
    });
  }
}
