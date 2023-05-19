import 'package:caf_face_authenticator/src/face_authenticator_api.dart';
import 'package:caf_face_authenticator/src/face_authenticator_exceptions.dart';
import 'package:caf_face_authenticator/src/face_authenticator_result.dart';
import 'package:cs_liveness_flutter/export.dart';

import 'package:flutter/cupertino.dart';

class FaceAuthenticator {
  final String clientId;
  final String clientSecret;
  final FaceAuthenticatorResult _result = FaceAuthenticatorResult();
  @visibleForTesting
  FaceAuthenticatorApi faceAuthenticatorApi;
  @visibleForTesting
  CsLiveness liveness;

  FaceAuthenticator(
    this.clientId,
    this.clientSecret,
    token,
    personId,
  )   : faceAuthenticatorApi = FaceAuthenticatorApi(token, clientId, clientSecret, personId),
        liveness = CsLiveness(
          clientId: clientId,
          clientSecret: clientSecret,
          vocalGuidance: false,
        );

  Future<FaceAuthenticatorResult> initialize() async {
    try {
      final livenessResult = await startLiveness();
      String sessionId = livenessResult.sessionId ?? '';
      _result.trackingId = sessionId;
      if (isLivenessResultValid(livenessResult)) {
        _result.imageBase64 = livenessResult.base64Image;
        _result.isAlive = await faceAuthenticatorApi.verifyLiveness(sessionId);
        _result.isMatch = await faceAuthenticatorApi.verifyFaceMatch(sessionId);
      }
      return _result;
    } on FaceAuthenticatorLivenessSdkException {
      rethrow;
    } on FaceAuthenticatorApiException {
      rethrow;
    } catch (exception, stacktrace) {
      throw FaceAuthenticatorUnknownException(exception, stacktrace);
    }
  }

  @visibleForTesting
  Future<CsLivenessResult> startLiveness() async {
    try {
      var livenessResult = await liveness.start();
      return livenessResult;
    } catch (e) {
      if (e is CSLivenessAuthException ||
          e is CSLivenessPermissionException ||
          e is CSLivenessCancelByUserException ||
          e is CSLivenessGenericException) {
        throw FaceAuthenticatorLivenessSdkException(e.toString());
      } else {
        rethrow;
      }
    }
  }

  @visibleForTesting
  bool isLivenessResultValid(CsLivenessResult result) {
    return result.real != null &&
        result.sessionId != null &&
        result.real == true;
  }
}
