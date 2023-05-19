class FaceAuthenticatorResult {
  bool isAlive;
  bool isMatch;
  String? trackingId;
  String? imageBase64;

  FaceAuthenticatorResult({
    this.isAlive = false,
    this.isMatch = false,
  });
}
