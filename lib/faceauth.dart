library faceauth;

import 'dart:convert';
import 'package:cs_liveness_flutter/cs_liveness_flutter.dart';
import 'package:http/http.dart' as http;

class FaceAuthResult {
  final bool isAlive;
  final bool isMatch;
  final String? sessionId;
  final String? imageBase64;
  final String? errorMessage;

  FaceAuthResult({
    required this.isAlive,
    required this.isMatch,
    this.sessionId,
    this.imageBase64,
    this.errorMessage,
  });
}

class FaceAuthApiResult {
  final bool isMatch;
  final String? errorMessage;

  FaceAuthApiResult({
    required this.isMatch,
    this.errorMessage,
  });
}

class FaceAuth {
  final Uri FACE_LIVENESS_URL =
      Uri.parse('https://api.public.caf.io/v1/sdks/faces/liveness-partner');

  final Uri FACE_MATCH_URL = Uri.parse(
      'https://api.public.caf.io/v1/sdks/faces/authentication-partner');

  final String token;
  final String clientId;
  final String clientSecret;
  final String personId;
  late final CsLiveness _liveness;
  FaceAuth(
    this.token,
    this.clientId,
    this.clientSecret,
    this.personId,
  ) {
    _liveness = CsLiveness(
      clientId: clientId,
      clientSecret: clientSecret,
      vocalGuidance: false,
    );
  }

  Future<FaceAuthResult> initialize() async {
    try {
      final result = await _liveness.start();

      if (result.real != null &&
          result.sessionId != null &&
          result.real == true) {
        String sessionId = result.sessionId ?? '';
        var responseFaceLiveness = await http.post(FACE_LIVENESS_URL,
            body: jsonEncode({
              'personId': personId,
              'sessionId': sessionId,
              'sdkVersion': 'Flutter-1.0.0',
            }),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            });

        if (responseFaceLiveness.statusCode == 200 &&
            result.sessionId != null) {
          var responseFaceMatch = await http.post(FACE_MATCH_URL,
              body: jsonEncode({
                'personId': personId,
                'sessionId': sessionId,
                'sdkVersion': 'Flutter-1.0.0',
              }),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json'
              });

          if (responseFaceMatch.statusCode != 200) {
            return FaceAuthResult(
              isAlive: true,
              isMatch: false,
              errorMessage: 'Fail to try face match',
              sessionId: sessionId,
              imageBase64: result.base64Image,
            );
          }

          return FaceAuthResult(
            isAlive: true,
            isMatch: jsonDecode(responseFaceMatch.body)['isMatch'],
            sessionId: sessionId,
            imageBase64: result.base64Image,
          );
        }
        return FaceAuthResult(
            isAlive: false,
            isMatch: false,
            errorMessage: 'Fail to register liveness usage',
            imageBase64: result.base64Image,
            sessionId: sessionId);
      }

      return FaceAuthResult(
        isAlive: false,
        isMatch: false,
      );
    } catch (e) {
      rethrow;
      return FaceAuthResult(
        isAlive: false,
        isMatch: false,
        errorMessage: e.toString(),
      );
    }
  }
}
