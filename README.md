# Introdução

Para usar o SDK de face authenticator da CAF, primeiro é necessário adicionar a depêndencia ao `pubspec.yaml`

```yaml
caf_face_authenticator:
    git:
      url: https://github.com/combateafraude/flutter-faceauth-sdk
      rev: 0.0.2
```

Após isso, rode os seguintes comandos para baixar a última versão do sdk:

```bash
flutter clean
flutter pub get
```

Com a dependência instalada, agora é possível instanciar um classe FaceAuthenticator

```dart
import 'package:caf_face_authenticator/caf_face_authenticator.dart';

bool isLiveness = false;
bool isMatch = false;

final faceAuthenticator = FaceAuthenticator(
    'client-id',
    'client-secret',
    'caf-mobile-token',
    'person-id (cpf)');

try {
    final result = await faceAuthenticator.initialize();
    isLiveness = result.isAlive;
    isMatch = result.isMatch;
} on FaceAuthenticatorLivenessSdkException catch (e) {
    debugPrint('error: $e');
} on FaceAuthenticatorApiException catch (e) {
    debugPrint('error: $e');
} on FaceAuthenticatorUnknownException catch (e) {
    debugPrint('error: $e');
}
```

O método `initialize` é o responsável por iniciar a captura e trazer o resultado do face authenticator e face liveness. O retorno segue a seguinte interface:

| Atributo | Descrição |
|---|---|
| isAlive (bool) | Resultado do Liveness |
| isMatch (bool)  | Resultado do FaceMatch |
| sessionId (String?)  | Id único da sessão do usuário (é fortemente recomendado o armazenamento desse valor para futura auditoria e rastreamento)  |
| imageBase64 (String?) | Captura da imagem em base64 para ser salva do lado do cliente, se necessário |

## Configurações específicas para cada plataforma

Para a aplicação funcionar corretamente, o applicationId/bundleIdentifier deve ser o mesmo que foi fornecido à CAF no momento da geração das chaves de API.

### Android

- Adicionar o seguinte trecho de código no arquivo `android/buid.gradle`:

```bash
def defaultPath = System.env.DIRNAME ?: System.env.PWD 
System.properties["ENV_FILE"] = defaultPath + "./../.gradle.env"
```

- Adicionar as seguintes permissões no arquivo `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA" />
```

- Adicionar o arquivo `.gradle.env` na raiz do projeto com as seguintes informações:

```bash
CS_LIVENESS_TEC_ARTIFACTS_FEED_URL= // valor fornecido pela CAF
CS_LIVENESS_TEC_ARTIFACTS_FEED_NAME= // valor fornecido pela CAF
CS_LIVINESS_TEC_USER= // valor fornecido pela CAF
CS_LIVINESS_TEC_PASS= // valor fornecido pela CAF
CS_LIVENESS_VERSION= // valor fornecido pela CAF
```

### iOS

- Adicionar o seguinte pod no arquivo `ios/Podfile`:

```pod
pod 'CSLivenessSDK', :git => '<INFORMAÇÃO_FORNECIDA_PELA_CAF>', :tag => '1.1.0'
```

- Adicionar os seguintes valores no arquivo `ios/Runner/info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Use camera</string>
```
