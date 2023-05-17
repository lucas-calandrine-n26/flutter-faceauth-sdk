import 'package:http/http.dart' as http;

class FaceAuthException implements Exception {
  final String message;

  FaceAuthException(this.message);

  @override
  String toString() => message;
}

class FaceAuthUnknownException extends FaceAuthException {
  final Object exception;
  final StackTrace stackTrace;

  FaceAuthUnknownException(this.exception, this.stackTrace)
      : super(exception.toString());
}

class FaceAuthLivenessSdkException extends FaceAuthException {
  FaceAuthLivenessSdkException(super.message);
}

class FaceAuthApiException implements FaceAuthException {
  final http.Response response;
  @override
  final String message;

  FaceAuthApiException(this.response, this.message);

  @override
  String toString() =>
      "message: $message | request: ${response.request?.url.path} | statusCode: ${response.statusCode} |body: ${response.body} ";
}

class FaceAuthLivenessApiException extends FaceAuthApiException {
  FaceAuthLivenessApiException(response)
      : super(response, 'Fail to register liveness usage');
}

class FaceAuthFaceMathApiException extends FaceAuthApiException {
  FaceAuthFaceMathApiException(response)
      : super(response, 'Fail to try face match');
}
