class FaceAuthResult {
  bool isAlive;
  bool isMatch;
  String? trackingId;
  String? imageBase64;

  FaceAuthResult({
    this.isAlive = false,
    this.isMatch = false,
  });
}
