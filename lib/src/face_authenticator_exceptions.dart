import 'package:http/http.dart' as http;

class FaceAuthenticatorException implements Exception {
  final String message;

  FaceAuthenticatorException(this.message);

  @override
  String toString() => message;
}

class FaceAuthenticatorUnknownException extends FaceAuthenticatorException {
  final Object exception;
  final StackTrace stackTrace;

  FaceAuthenticatorUnknownException(this.exception, this.stackTrace)
      : super(exception.toString());
}

class FaceAuthenticatorLivenessSdkException extends FaceAuthenticatorException {
  FaceAuthenticatorLivenessSdkException(super.message);
}

class FaceAuthenticatorApiException implements FaceAuthenticatorException {
  final http.Response response;
  @override
  final String message;

  FaceAuthenticatorApiException(this.response, this.message);

  @override
  String toString() =>
      "message: $message | request: ${response.request?.url.path} | statusCode: ${response.statusCode} |body: ${response.body} ";
}

class FaceAuthenticatorLivenessApiException extends FaceAuthenticatorApiException {
  FaceAuthenticatorLivenessApiException(response)
      : super(response, 'Fail to register liveness usage');
}

class FaceAuthenticatorFaceMathApiException extends FaceAuthenticatorApiException {
  FaceAuthenticatorFaceMathApiException(response)
      : super(response, 'Fail to try face match');
}
