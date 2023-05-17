import 'dart:io';

import 'package:cs_liveness_flutter/cs_liveness_exceptions.dart';
import 'package:cs_liveness_flutter/cs_liveness_result.dart';
import 'package:faceauth/faceauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../mock/mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FaceAuth faceAuth;
  final faceAuthApiMock = FaceAuthApiMock();
  final csLivenessMock = CsLivenessMock();
  final csLivenessResultStub = CsLivenessResult(
    base64Image: 'base64Image',
    image: null,
    sessionId: 'SessionId',
    real: true,
  );

  setUp(() {
    when(() => csLivenessMock.start())
        .thenAnswer((_) async => csLivenessResultStub);
    when(() => faceAuthApiMock.verifyLiveness(any()))
        .thenAnswer((_) async => true);
    when(() => faceAuthApiMock.verifyFaceMatch(any()))
        .thenAnswer((_) async => true);

    faceAuth = FaceAuth('clientId', 'clientSecret', 'token', 'personId');
    faceAuth.liveness = csLivenessMock;
    faceAuth.faceAuthApi = faceAuthApiMock;
  });

  group('GIVEN a FaceAuth instance ', () {
    test(
      'WHEN call to initialize THEN it should return a valid FaceAuthResult',
      () async {
        var result = await faceAuth.initialize();
        expect(result.isAlive, true);
        expect(result.isMatch, true);
        expect(result.trackingId, 'SessionId');
        verify(() => csLivenessMock.start());
      },
    );

    test(
      'AND the CsLiveness will return a invalid result WHEN call to initialize THEN it should a FaceAuthResult with isAlive and isMatch as false',
      () async {
        var invalidCsLivenessResult = CsLivenessResult(
          base64Image: null,
          image: null,
          sessionId: null,
          real: false,
        );
        when(() => csLivenessMock.start())
            .thenAnswer((_) async => invalidCsLivenessResult);
        var result = await faceAuth.initialize();
        expect(result.isAlive, false);
        expect(result.isMatch, false);
        expect(result.trackingId, '');
        verify(() => csLivenessMock.start());
      },
    );

    test(
      'AND the initialize will throw a FaceAuthLivenessApiException WHEN to call initialize THEN it should rethrow the exception',
      () {
        when(() => faceAuthApiMock.verifyLiveness(any())).thenAnswer(
          (_) async {
            var response = Response("{}", HttpStatus.notFound);
            throw FaceAuthLivenessApiException(response);
          },
        );
        expect(() async => await faceAuth.initialize(),
            throwsA(isA<FaceAuthApiException>()));
      },
    );

    test(
      'AND the initialize will throw a FaceAuthFaceMathApiException WHEN to call initialize THEN it should rethrow the exception',
      () {
        when(() => faceAuthApiMock.verifyFaceMatch(any())).thenAnswer(
          (_) async {
            var response = Response("{}", HttpStatus.notFound);
            throw FaceAuthFaceMathApiException(response);
          },
        );
        expect(() async => await faceAuth.initialize(),
            throwsA(isA<FaceAuthApiException>()));
      },
    );

    test(
      'AND the initialize will throw an exception WHEN to call initialize THEN it should throw FaceAuthUnknownException',
      () {
        when(() => csLivenessMock.start()).thenAnswer(
          (_) async => (throw Exception()),
        );
        expect(() async => await faceAuth.initialize(),
            throwsA(isA<FaceAuthUnknownException>()));
      },
    );

    test(
      'WHEN call to startLiveness THEN it should return a valid CsLivenessResult',
      () async {
        var result = await faceAuth.startLiveness();
        expect(result.real, true);
        expect(result.image, null);
        expect(result.sessionId, 'SessionId');
        expect(result.base64Image, 'base64Image');
        verify(() => csLivenessMock.start());
      },
    );

    test(
      'AND the CsLiveness will throw an unmapped exception WHEN to call startLiveness THEN it should rethrow the exception',
      () {
        when(() => csLivenessMock.start()).thenAnswer(
          (_) async => throw Exception(),
        );
        expect(() async => await faceAuth.startLiveness(),
            throwsA(isA<Exception>()));
        verify(() => csLivenessMock.start());
      },
    );

    group(
        'AND the CsLiveness will throw an exception WHEN to call startLiveness THEN it should throw FaceAuthLivenessSdkException',
        () {
      final testValues = [
        CSLivenessAuthException(),
        CSLivenessPermissionException(),
        CSLivenessCancelByUserException(),
        CSLivenessGenericException(
            message: "Instance of 'CSLivenessGenericException'"),
      ];
      for (final exception in testValues) {
        test(exception.toString(), () {
          when(() => csLivenessMock.start())
              .thenAnswer((_) async => throw exception);
          expect(() async => await faceAuth.startLiveness(),
              throwsA(isA<FaceAuthLivenessSdkException>()));
          verify(() => csLivenessMock.start());
        });
      }
    });

    test(
      'AND a valid CsLivenessResult WHEN check if the liveness result is valid THEN it should return true',
      () {
        var livenessResultStub = CsLivenessResult(
          base64Image: 'base64Image',
          image: null,
          sessionId: 'SessionId',
          real: true,
        );
        expect(
          faceAuth.isLivenessResultValid(livenessResultStub),
          true,
        );
      },
    );

    test(
      'AND a CsLivenessResult with the parameter real as false WHEN check if the liveness result is valid THEN it should return false',
      () {
        var real = false;
        var livenessResultStub = CsLivenessResult(
          base64Image: 'base64Image',
          image: null,
          sessionId: 'SessionId',
          real: real,
        );
        expect(
          faceAuth.isLivenessResultValid(livenessResultStub),
          false,
        );
      },
    );

    test(
      'AND a CsLivenessResult with sessionId and real as null WHEN check if the liveness result is valid THEN it should return false',
      () {
        var livenessResultStub = CsLivenessResult(
          base64Image: 'base64Image',
          image: null,
          sessionId: null,
          real: null,
        );
        expect(
          faceAuth.isLivenessResultValid(livenessResultStub),
          false,
        );
      },
    );
  });
}
