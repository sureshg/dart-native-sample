## Dart2Native HTTPS & [RSocket][rsocket] sample app

 `AOT` compiles a `Dart` app to native executable for `Windows`, `Linux` and `macOS` using [Dart2Native][dart2native_url] tool.

[![GitHub Workflow Status][shieldio_img]][gha_url] 
[![Dart][dart_img]][dart_url]
[![Pub Version][doc_img]][doc_url]
[![Style guide][sty_img]][sty_url]

#### Build

 - Install [Dart SDK](https://dart.dev/get-dart)
   
   ```bash
   $ brew tap dart-lang/dart
   $ brew install dart
   ```
 - Build
 
    ```bash
    $ dart2native bin/main.dart -DdefaultPort=8445 -o test-server 
    
    # Running the server
    $ ./test-server --help 
    $ ./test-server -s
    $ ./test-server -l https://google.com -s
    ```

#### Generate X509 Cert

```bash
$ openssl req -newkey rsa:4096 \
    -new -nodes -x509 \
    -days 3650 \
    -out cert.pem \
    -keyout key.pem \
    -subj "/C=US/ST=California/L=San Jose/O=Suresh/OU=Dev/CN=localhost"
```

#### Misc

 * https://hub.docker.com/r/google/dart-runtime
 * https://github.com/cedx/setup-dart
 * https://github.com/DanTup/gh-actions
 * https://github.com/DanTup/dart-native-executables
 * https://tio.run/#powershell
 
[rsocket]: https://rsocket.io
[dart2native_url]: https://dart.dev/tools/dart2native

[sty_url]: https://pub.dev/packages/pedantic
[sty_img]: https://img.shields.io/badge/style-pedantic-26C6DA.svg?style=for-the-badge&logo=Dart&logoColor=26C6DA

[dart_url]: https://dart.dev/get-dart#release-channels
[dart_img]: https://img.shields.io/docker/v/google/dart?color=40c4ff&label=Dart&logo=dart&logoColor=40c4ff&style=for-the-badge

[doc_url]: https://pub.dev/documentation/rsocket/latest/
[doc_img]: https://img.shields.io/pub/v/rsocket?color=orange&label=rsocket&logo=dart&logoColor=orange&style=for-the-badge

[gha_url]: https://github.com/sureshg/dart-native-sample/actions
[gha_img]: https://github.com/sureshg/dart-native-sample/workflows/Dart%20Build/badge.svg?branch=master
[shieldio_img]: https://img.shields.io/github/workflow/status/sureshg/dart-native-sample/Dart%20Build?color=green&label=Dart%20Build&logo=Github-Actions&logoColor=green&style=for-the-badge
