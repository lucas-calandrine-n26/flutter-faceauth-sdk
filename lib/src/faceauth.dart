import 'package:cs_liveness_flutter/export.dart';
import 'package:faceauth/src/faceauth_api.dart';
import 'package:faceauth/src/faceauth_exceptions.dart';
import 'package:faceauth/src/faceauth_result.dart';
import 'package:flutter/cupertino.dart';

class FaceAuth {
  final String clientId;
  final String clientSecret;
  final FaceAuthResult _result = FaceAuthResult();
  @visibleForTesting
  FaceAuthApi faceAuthApi;
  @visibleForTesting
  CsLiveness liveness;

  FaceAuth(
    this.clientId,
    this.clientSecret,
    token,
    personId,
  )   : faceAuthApi = FaceAuthApi(token, clientId, clientSecret, personId),
        liveness = CsLiveness(
          clientId: clientId,
          clientSecret: clientSecret,
          vocalGuidance: false,
        );

  Future<FaceAuthResult> initialize() async {
    try {
      final livenessResult = await startLiveness();
      String sessionId = livenessResult.sessionId ?? '';
      _result.trackingId = sessionId;
      if (isLivenessResultValid(livenessResult)) {
        _result.imageBase64 = livenessResult.base64Image;
        _result.isAlive = await faceAuthApi.verifyLiveness(sessionId);
        _result.isMatch = await faceAuthApi.verifyFaceMatch(sessionId);
      }
      return _result;
    } on FaceAuthLivenessSdkException {
      rethrow;
    } on FaceAuthApiException {
      rethrow;
    } catch (exception, stacktrace) {
      throw FaceAuthUnknownException(exception, stacktrace);
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
        throw FaceAuthLivenessSdkException(e.toString());
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
